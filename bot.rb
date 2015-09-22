# -*- encoding: utf-8 -*-
require 'active_record'
require 'sqlite3'
require 'twitter'

dbname = 'twitter.sqlite3'
account = 'YOUR BOT ACCOUNT'
target = 'asmsuechan'

######### HOW TO USE ########
# if target tweet, your bot #
# replies "fuck you!!"      #
#############################

## create database(sqlite3) by activerecord
ActiveRecord::Base.establish_connection(
	adapter:'sqlite3',
	database:dbname
)

class InitialSchema < ActiveRecord::Migration
	def self.up
		create_table :tweets do |t|
			t.string :text
			t.string :tweet_id
		end
	end

	def self.down
		drop_tables :tweets
	end
end

if not File.exist?(dbname)
	InitialSchema.migrate(:up)
end

class Tweet < ActiveRecord::Base
end

#set twitter api keies
#you must get api key in https://dev.twitter.com/
client = Twitter::REST::Client.new do |config|
  config.consumer_key       = "YOUR CONSUMER KEY"
  config.consumer_secret    = "YOUR CONSUMER SECRET" 
  config.access_token       = "YOUR ACCESS TOKEN" 
  config.access_token_secret= "YOUR ACCESS TOKEN SECRET"
end

if config.friendship?(target, account)
	client.user_timeline(target,{count:10}).each do |friends_tweet|
		tweet = client.status(friends_tweet.id)
		tweet_text = tweet.text
		tweet_id = tweet.id
		if tweet_text.include?("@")==false
		#prevent involve others
			if Tweet.find_by(tweet_id:tweet_id)==nil
				Tweet.create(tweet_id:tweet_id.to_s,text:tweet_text)
				#write reply here
				#try not to send reply at running first time
				client.update("@#{target}fuck you!!!",in_reply_to_status_id:tweet_id)
				puts "send a reply"
			else
				puts "nothing new post"
				break
			end
		end
	end

	puts "------------test---------------"
	#client.update("test")
	#puts "posted "test""
	
	puts "-------------------------------"
	Tweet.all.each do |t|
		print t.tweet_id
		puts t.text
	end
	puts "-------------------------------"
end
