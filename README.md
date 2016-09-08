# Cloud Vision Gem

Cloud Vision is a Ruby gem that makes using [Google's Cloud Vision](https://cloud.google.com/vision/) simple and clean. The gem is written concisely and requires no other dependencies.

```ruby
require 'cloud_vision'

raw_result = CloudVision::Api.new( api_key ).analyze( image_file, :landmarks )
result = CloudVision::Parser.parse_analysis( raw_result )

# {
#   labels: [{:description=>"Eiffel Tower", :locale=>nil, :score=>59.66081}]
# }
```

## CloudVision::Api.analyze
**analyze( image_file, tests ) => [json] Raw Response**

```ruby
# Run all tests
raw_result = CloudVision::Api.new( api_key ).analyze( image_file, :all )

# Run some tests
raw_result = CloudVision::Api.new( api_key ).analyze( image_file, [:faces, :labels] )
```

*Note*: Google's Cloud Vision implements a number of possible tests it can run on images. This function allows you to them them all, using `:all` or can pass an array. Possible values are:

- `:safety` - tests image safesearch-ability
- `:facial` - locales faces and runs sentiment analysis on them
- `:labels` - finds appropriate tags for the image
- `:text` - transcribes any text in the image
- `:logos` - marks and labels logos
- `:landmarks` - recognizes common landmarks (White House, Eiffel Tower, etc)
- `:properties` - most common colors

## CloudVision::Parser.parse_analysis( raw_response )
**parse_analysis( raw_response ) => [hash] Parsed analysis**

```ruby
raw_result = CloudVision::Api.new( api_key ).analyze( image_file, :all )
analysis = CloudVision::Parser.parse_analysis( raw_result )
```

## Parsed formats
### Faces Test
```javascript
{
  faces: [
    {
      face: {
        x: 393,
        y: 179,
        width: 99,
        height: 115
      },
      quality: {
        under_exposed: -2,
        blurred: -2,
        headwear: -2
      },
      sentiment: {
        joy: 3,
        sorrow: -2,
        anger: -2,
        surprise: -2
      },
      confidence: 0.619328
    }
  ]
}
```

### Safety Test
```javascript
{
  safety: {
    adult: -1,
    spoof: -2,
    medical: -1,
    violence: -2
  }
}
```

### Text Test
```javascript
{
  text: [
    {
      description: "Fresh Coffee",
      locale: "en"
    }
  ]
}
```

### Logo Test
```javascript
{
  logos: [
    {
      description: "Under Armour",
      score: 52.81474000000001
    }
  ]
}
```

### Labels Test
```javascript
{
  labels: [
    {
      description: "vacation",
      score: 92.342234
    },
    {
      description: "boating",
      score: 76.322818
    },
    {
      description: "yacht",
      score: 57.539123000000004
    }
  ]
}
```

### Landmark Test
```javascript
{
  landmarks: [
    {
      description: "Eiffel Tower",
      score: 59.66081
    }
  ]
}
```

### Properties Test
```javascript
{
  properties: {
    colors: [
      {
        hex: "#4E7EBE", 
        score: 33.334911, 
        percentage: 16.3028
      },
      {
        hex: "#E7EBEE", 
        score: 7.284198, 
        percentage: 6.1303589
      },
      {
        hex: "#4A566F", 
        score: 6.377968200000001, 
        percentage: 0.957127
      }
    ]
  }
}
```

