; extends

((interpolation
  (raw_text) @injection.content)
  (#set! injection.language "javascript"))

((directive_attribute
   (quoted_attribute_value
     (attribute_value) @injection.content)
   (#set! injection.language "javascript")))
