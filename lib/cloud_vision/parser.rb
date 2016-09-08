require 'json'

module CloudVision
	class Parser
		RESPONSE_LABELS = {
			SAFETY_TEST => 'safeSearchAnnotation',
			FACIAL_TEST => 'faceAnnotations',
			LABEL_TEST => 'labelAnnotations',
			TEXT_TEST => 'textAnnotations',
			LOGO_TEST => 'logoAnnotations',
			LANDMARK_TEST => 'landmarkAnnotations',
			PROPERTIES_TEST => 'imagePropertiesAnnotation'
		}.freeze

		RESPONSE_SCALE = {
			'VERY_UNLIKELY' => -2,
			'UNLIKELY' => -1,
			'UNKNOWN' => 0,
			'POSSIBLE' => 1,
			'LIKELY' => 2,
			'VERY_LIKELY' => 3
		}.freeze

		def self.parse_analysis( analysis )
			parsed_data = {}

			if analysis && analysis.is_a?( String )
				analysis = JSON.parse( analysis )
			elsif !analysis || !analysis.is_a?( Hash )
				raise( 'Parsing Failed. Analysis must be valid JSON' )
			end

			if analysis[ RESPONSE_LABELS[SAFETY_TEST] ]
				new_data = parse_safety( analysis )
				parsed_data[ SAFETY_TEST ] = new_data
			end

			if analysis[ RESPONSE_LABELS[FACIAL_TEST] ]
				new_data = parse_faces( analysis )
				parsed_data[ FACIAL_TEST ] = new_data
			end

			if analysis[ RESPONSE_LABELS[LABEL_TEST] ]
				new_data = parse_entity( analysis, LABEL_TEST )
				parsed_data[ LABEL_TEST ] = new_data
			end

			if analysis[ RESPONSE_LABELS[TEXT_TEST] ]
				new_data = parse_entity( analysis, TEXT_TEST )
				parsed_data[ TEXT_TEST ] = new_data
			end

			if analysis[ RESPONSE_LABELS[LOGO_TEST] ]
				new_data = parse_entity( analysis, LOGO_TEST )
				parsed_data[ LOGO_TEST ] = new_data
			end

			if analysis[ RESPONSE_LABELS[LANDMARK_TEST] ]
				new_data = parse_entity( analysis, LANDMARK_TEST )
				parsed_data[ LANDMARK_TEST ] = new_data
			end

			if analysis[ RESPONSE_LABELS[PROPERTIES_TEST] ]
				new_data = parse_properties( analysis )
				parsed_data[ PROPERTIES_TEST ] = new_data
			end

			parsed_data
		end

		def self.parse_safety( analysis )
			processed_data = {}

			if analysis[ RESPONSE_LABELS[SAFETY_TEST] ]
	      analysis[ RESPONSE_LABELS[SAFETY_TEST] ].each do |risk_test, value|
	        processed_data[ risk_test.to_sym ] = RESPONSE_SCALE[ value ]
	      end
			end

			processed_data
		end

		def self.parse_faces( analysis )
			processed_data = []

	    if analysis[ RESPONSE_LABELS[FACIAL_TEST] ]
	      analysis[ RESPONSE_LABELS[FACIAL_TEST] ].each do |face_data|
	        annotations = {}

	        # Only include face data for users with 4 bounding points
	        if face_data['boundingPoly']['vertices'].length == 4
	          top_left = face_data['boundingPoly']['vertices'][ 0 ]
	          bottom_right = face_data['boundingPoly']['vertices'][ 2 ]

	          annotations[ :face ] = {
	            x: top_left['x'],
	            y: top_left['y'],
	            width: bottom_right['x'].to_i - top_left['x'].to_i,
	            height: bottom_right['y'].to_i - top_left['y'].to_i
	          }
	        end

	        # Find the confidence in the image parse
	        annotations[ :confidence ] = face_data[ 'detectionConfidence' ]

	        # Store the image quality metrics
	        annotations[ :quality ] = {
	          under_exposed: RESPONSE_SCALE[ face_data['underExposedLikelihood'] ],
	          blurred: RESPONSE_SCALE[ face_data['blurredLikelihood'] ],
	          headwear: RESPONSE_SCALE[ face_data['headwearLikelihood'] ]
	        }

	        # Parse the sentiment analysis data
	        annotations[ :sentiment ] = {
	          joy: RESPONSE_SCALE[ face_data['joyLikelihood'] ],
	          sorrow: RESPONSE_SCALE[ face_data['sorrowLikelihood'] ],
	          anger: RESPONSE_SCALE[ face_data['angerLikelihood'] ],
	          surprise: RESPONSE_SCALE[ face_data['surpriseLikelihood'] ]
	        }

	        processed_data << annotations
	      end
	    end

			processed_data
		end

		def self.parse_entity( analysis, target )
			processed_data = []

			if analysis[ RESPONSE_LABELS[target] ]
				analysis[ RESPONSE_LABELS[target] ].each do |label_data|
					entity_data = {
						description: label_data[ 'description' ],
						locale: label_data[ 'locale' ],
						score: label_data[ 'score' ].to_f * 100,
						confidence: label_data[ 'confidence' ].to_f * 100,
						relevance: label_data[ 'topicality' ].to_f * 100
					}

					# Some entity responses do not report confidence or relevance data
					if entity_data[ :confidence ] == 0 && entity_data[ :relevance ] == 0
						entity_data.delete( :relevance )
						entity_data.delete( :confidence )
					end

					# Text filters include no score either.
					if entity_data[ :score ] == 0
						entity_data.delete( :score )
					end

					# Landmarks include no locale either.
					if !entity_data[ :locale ]
						entity_data.delete( :locale )
					end

					processed_data << entity_data
				end
			end

			processed_data
		end

		def self.parse_properties( analysis )
			processed_data = {}

			properties_data = analysis[ RESPONSE_LABELS[PROPERTIES_TEST] ]
			if properties_data && properties_data[ 'dominantColors' ]
				properties_data = properties_data[ 'dominantColors' ][ 'colors' ]
				processed_data[ :colors ] = []

				properties_data.each do |color_data|
					red = color_data[ 'color' ][ 'red' ].to_i.to_s( 16 )
					green = color_data[ 'color' ][ 'green' ].to_i.to_s( 16 )
					blue = color_data[ 'color' ][ 'blue' ].to_i.to_s( 16 )

					processed_data[ :colors ] << {
						hex: "##{red}#{green}#{blue}".upcase,
						score: color_data[ 'score' ].to_f * 100,
						percentage: color_data[ 'pixelFraction' ].to_f * 100
					}
				end
			end

			processed_data
		end
	end
end
