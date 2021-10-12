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

# resp = s3.list_buckets
# resp.buckets.map(&:name)

# puts resp

def upload_file(file_path)
    uid = SecureRandom.uuid
    File.open(file_path, 'rb') do |file|
        @s3.put_object({
            body: file,
            bucket: "hotdrop-files",
            key: "#{uid}",
            server_side_encryption: "AES256"
            # content_md5: md5
        })
    end
    uid
end

file_uid = upload_file 'test-file.txt'
puts "Uploaded file #{file_uid}"

# FILE = 'file'

# get '/' do
#     'Hello World'
# end

# before do
#     @file_path = @params[FILE]
#     puts "received file path #{@file_path}"
#     if File.file?(@file_path)
#         pass
#     else
#         halt 204
#     end
# end

# get '/hash' do
#     Digest::MD5.hexdigest(File.read(params[@file_path]))
# end

# get '/file' do
#     send_file @file_path, :filename => @file_path.split('/')[-1]
# end


# # md5sum <file_path>