module CloudVision
	SAFETY_TEST			= :safety
	FACIAL_TEST			= :faces
	LABEL_TEST				= :labels
	TEXT_TEST				= :text
	LOGO_TEST				= :logos
	LANDMARK_TEST		= :landmarks
	PROPERTIES_TEST	= :properties

	require 'cloud_vision/api'
	require 'cloud_vision/parser'
end
