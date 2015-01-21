require 'rubygems'
require 'pp'
require 'json-schema-generator'
require 'json-schema'
 
module ValidateJSONGem
        class ResponseJSON
                def initialize(fileS, jsonRD)
                        @fileS = fileS
                        @jsonRD = jsonRD
                end
 
                def check?
                        fileSchema = $fileS ? $fileS : 'Master.json' # Input File to Generate Master Schema
                        jsonResponseData = $jsonRD ? $jsonRD : 'SuccessResponse.json' # Dynamic Input from Response
                        # Generate schema
                        strpp = JSON::SchemaGenerator.generate fileSchema, File.read(fileSchema), {:schema_version => 'draft3'}
                        schema = JSON.parse(strpp)
                        # Read from file
                        data = JSON.parse(IO.read(jsonResponseData))
                        begin
                                pp JSON::Validator.fully_validate(schema, data, :strict => true, :errors_as_objects => true)
                                #JSON::Validator.validate!(schema, data)
                        rescue JSON::Schema::ValidationError
                                puts $!.message
                        end
                end
        end
end
