## Cloud Vision Gem

```ruby
require 'cloud_vision'

raw_result = CloudVision::Api.new( api_key ).analyze( image_file )
result = CloudVision::Parser.parse_analysis( raw_result )
```
