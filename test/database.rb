require 'aws-sdk-dynamodb'
require 'aws-sdk-core'
require 'json'

TABLE_NAME = 'hotdrop'

class Database
    def initialize ()
        creds = JSON.load(File.read('secrets.json'))
        @dynamo = Aws::DynamoDB::Client.new(
            region: 'eu-west-2', 
            credentials: Aws::Credentials.new(
                creds['accessKeyId'], 
                creds['secretAccessKey']))
    end

    def insert_mapping(id, uid)
        @dynamo.put_item({
            item: {
                "id" => id,
                "uid" => uid
            },
            table_name: TABLE_NAME
        })
    end
    
    def get_item(id)
        @dynamo.get_item({
            key: {"id" => id},
            table_name: TABLE_NAME
        })
    end
end