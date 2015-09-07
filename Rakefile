require './selenium.rb'

desc "mdmからcsvをダウンロードしてS3にアップロードする"
task :devicelist do
  include Selenium
  download_csv
  upload_s3
end

