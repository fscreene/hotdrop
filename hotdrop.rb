# require 'sinatra'
require 'digest/md5'
require 'aws-sdk-s3'
require 'aws-sdk-core'
require 'json'
require 'securerandom'

creds = JSON.load(File.read('secrets.json'))
@s3 = Aws::S3::Client.new(
    region: 'eu-west-2', 
    credentials: Aws::Credentials.new(
        creds['accessKeyId'], 
        creds['secretAccessKey']))

def upload_file(file_path)
    uid = SecureRandom.uuid
    File.open(file_path, 'rb') do |file|
        @s3.put_object({
            body: file,
            bucket: "hotdrop-files",
            key: "#{uid}",
            server_side_encryption: "AES256"
        })
    end
    uid
end