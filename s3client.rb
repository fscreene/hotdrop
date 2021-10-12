require 'aws-sdk-s3'
require 'aws-sdk-core'
require 'json'
require 'securerandom'

S3Response = Struct.new(:path, :ext)

class S3Client
    def initialize
        creds = JSON.load(File.read('secrets.json'))
        @s3 = Aws::S3::Client.new(
            region: 'eu-west-2', 
            credentials: Aws::Credentials.new(
                creds['accessKeyId'], 
                creds['secretAccessKey']))
    end

    def upload_file(file_path)
        uid = SecureRandom.uuid
        ext = file_path.split('/')[-1].split('.')[1..-1].join('.')
        File.open(file_path, 'rb') do |file|
            @s3.put_object({
                body: file,
                bucket: "hotdrop-files",
                key: "#{uid}",
                server_side_encryption: "AES256",
                metadata: {
                    "ext" => "#{ext}"
                }
            })
        end
        uid
    end

    def get_object(key)
        local_path = "./tmp/dl/s3-#{key}"
        object = @s3.get_object({
            bucket: "hotdrop-files",
            key: "#{key}",
            response_target: "#{local_path}"
        })
        puts "content-type: #{object.metadata}"
        S3Response::new(local_path, object.metadata['ext'])
    end
end