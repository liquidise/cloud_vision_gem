## Cloud Vision Gem

Cloud Vision is a Ruby gem that makes using [Google's Cloud Vision](https://cloud.google.com/vision/) simple and clean. The gem is written in simple ruby and requires no other dependencies.

```ruby
require 'cloud_vision'

raw_result = CloudVision::Api.new( api_key ).analyze( image_file, :all )
result = CloudVision::Parser.parse_analysis( raw_result )
```

### CloudVision::Api.analyze
**analyze( image_file, tests ) => [json] Raw Response**
```ruby
# Run all tests
raw_result = CloudVision::Api.new( api_key ).analyze( image_file, :all )

# Run some tests
raw_result = CloudVision::Api.new( api_key ).analyze( image_file, [:facial, labels] )
```

*Note*: Google's Cloud Vision implements a number of possible tests it can run on images. This function allows you to them them all, using `:all` or can pass an array. Possible values are:

- `:safety` - tests image safesearch-ability
- `:facial` - locales faces and runs sentiment analysis on them
- `:labels` - finds appropriate tags for the image
- `:text` - transcribes any text in the image
- `:logos` - marks and labels logos
- `:landmarks` - recognizes common landmarks (White House, Eiffel Tower, etc)
- `:properties` - most common colors

### CloudVision::Parser.parse_analysis( raw_response )