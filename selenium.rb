require 'nokogiri'
require 'capybara'
require 'selenium-webdriver'
require 'yaml'

module Selenium
  @@mdm_config = YAML.load_file('config.yml')

  def download_csv
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile["browser.download.folderList"] = 2 # 0:Desktop 1:System Default 2:User Defined
    profile["browser.download.dir"] = @@mdm_config['download_dir']
    profile["browser.helperApps.neverAsk.saveToDisk"] = 'text/csv'

    Capybara.default_selector = :css
    Capybara.register_driver :remote_firefox do |app|
      Capybara::Selenium::Driver.new(app, :profile => profile)
    end

    session = Capybara::Session.new(:remote_firefox)

    url = "https://bizconcier-dm.com"
    session.visit(url)

    session.find(:css, "#longinFrm>table:nth-child(5)>tbody>tr:nth-child(1)>td>input").set(@@mdm_config['dm_code'])
    session.find(:css, "#longinFrm>table:nth-child(5)>tbody>tr:nth-child(2)>td>input").set(@@mdm_config['login_id'])
    session.find(:css, "#longinFrm>table:nth-child(5)>tbody>tr:nth-child(3)>td>input").set(@@mdm_config['password'])
    session.find(:css, "#submit").click
    puts "login"

    begin
      session.find(:css, "#gnavi>li:nth-child(1)>a>img").click
      session.find(:css, "#device_csv").click
      puts 'download_csv'
    rescue => e
      puts e.message
    ensure
      sleep 5
      session.find(:css, "#headArea>ul>li:nth-child(2)>a>img").click
      puts "logout"
    end
  end

  def upload_s3
    require 'find'
    Find.find('./') do |file|
      path, name = File.split(file)
      if /^#{@@mdm_config['dm_code']}_#{@@mdm_config['owner_name']}_デバイス情報一覧_(\d+)/ =~ name
        new_name = "devicelist_#{$1}.csv"
        puts "renaming #{name} to #{new_name}"
        File.rename(name, new_name)

        require 'aws-sdk'
        s3 = Aws::S3::Resource.new(region:@@mdm_config['aws']['region'])
        obj = s3.bucket(@@mdm_config['aws']['s3']['bucket']).object("#{@@mdm_config['aws']['s3']['path']}#{new_name}")
        obj.upload_file("./#{new_name}")
        break
      end
    end
  end
end
