require 'digest/md5'
require 'aws-sdk-dynamodb'
require 'aws-sdk-core'
require 'json'
require 'securerandom'
require './phrase-generator.rb'
require './database.rb'
require './s3client.rb'
require 'sinatra'

TABLE_NAME = 'hotdrop'

generator = PhraseGenerator::new

db = Database::new
s3 = S3Client::new


get '/' do
    send_file File.join(settings.public_folder, 'index.html')
end
  

get '/file/:id' do
    response = db.get_item(params['id'])
    key = response[:item]['uid']
    s3response = s3.get_object(key)
    send_file s3response[:path], :filename => "#{params['id']}.#{s3response[:ext]}"
end

post '/file' do
    if params[:file] && params[:file][:filename]
        filename = params[:file][:filename]
        file = params[:file][:tempfile]
        path = "./tmp/#{filename}"

        # Write file to disk
        File.open(path, 'wb') do |f|
            f.write(file.read)
        end

        id = generator.generate_phrase
        uid = s3.upload_file(path)
        logger.info "Mapping uploaded file #{filename} as #{id} => #{uid}"
        db.insert_mapping(id, uid)

        File.delete(path) if File.exist?(path)
    else
        status 400
    end

end


# File.delete(path) if File.exist?(path)




# Cache clear 
# Thread.new do
#     sleep(5) # seconds
#     #do stuff
# end


# insert_mapping(generator.generate_phrase, SecureRandom.uuid)
# item = get_item('cavernously-flashy-croaw')
# puts "oh no" unless item['item'] != nil