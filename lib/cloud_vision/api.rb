require 'net/https'
require 'base64'
require 'json'

module CloudVision
	class Api
		def initialize( api_key )
			@uri = URI( "https://vision.googleapis.com/v1/images:annotate?key=#{api_key}" )

			@cloud_vision = Net::HTTP.new( @uri.host, @uri.port )
			@cloud_vision.use_ssl = true
		end

		def analyze( image_file, tests, options={} )
			post_data = {
				requests: [ {
					image: {
						content: Base64.strict_encode64( image_file.read )
					},
					features: build_feature_requests( tests )
				} ]
			}

			response = send_request( post_data )

			return_format = response.body

			if return_format && !return_format.empty?
				return_format = JSON.parse( return_format )
				return_format = return_format[ 'responses' ].first
			end

			return_format
		end

		private

		def send_request( body )
			request = Net::HTTP::Post.new( @uri, {'Content-Type' => 'application/json'} )
			request.body = JSON.generate( body )

			@cloud_vision.request( request )
		end

		def build_feature_requests( tests )
			features = []

			if !tests.is_a?( Array )
				tests = [ tests ]
			end

			tests.each do |detection_test|
				filters = []

				detection_test = detection_test.to_sym
				if detection_test == FACIAL_TEST || detection_test == :all
					filters << { type: 'FACE_DETECTION', max_results: 10 }
				end

				if detection_test == TEXT_TEST || detection_test == :all
					filters << { type: 'TEXT_DETECTION', max_results: 10 }
				end

				if detection_test == LABEL_TEST || detection_test == :all
					filters << { type: 'LABEL_DETECTION', max_results: 10 }
				end

				if detection_test == LOGO_TEST || detection_test == :all
					filters << { type: 'LOGO_DETECTION', max_results: 10 }
				end

				if detection_test == LANDMARK_TEST || detection_test == :all
					filters << { type: 'LANDMARK_DETECTION', max_results: 10 }
				end

				if detection_test == SAFETY_TEST || detection_test == :all
					filters << { type: 'SAFE_SEARCH_DETECTION', max_results: 1 }
				end

				if detection_test == PROPERTIES_TEST || detection_test == :all
					filters << { type: 'IMAGE_PROPERTIES', max_results: 1 }
				end

				if filters.empty?
					raise( "Unrecognized test: #{detection_test.inspect}")
				end

				features += filters
			end

			features
		end
	end
end
