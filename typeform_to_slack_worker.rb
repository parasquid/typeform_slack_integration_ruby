#!/usr/bin/env ruby

require 'httparty'
require 'data_mapper'
require 'dotenv'
Dotenv.load

DataMapper.setup(:default, "sqlite://#{Dir.pwd}/people.db")

class Question
  include DataMapper::Resource

  property :id, Serial
  property :q_id, String, required: true
  property :question, Text, required: true
end

class Response
  include DataMapper::Resource
  has n, :answers
  has 1, :metadata
  has n, :hidden
  has 1, :status

  property :id, Serial
  property :r_id, String, required: true
  property :completed, Boolean, required: true
  property :token, String
  property :locked, Boolean
end

class Answer
  include DataMapper::Resource
  belongs_to :response, key: true

  property :id, Serial
  property :q_id, String, required: true
  property :answer, Text
end

class Metadata
  include DataMapper::Resource
  belongs_to :response, key: true

  property :id, Serial
  property :browser, Text
  property :platform, Text
  property :date_land, DateTime
  property :date_submit, DateTime
  property :user_agent, Text
  property :referer, String
  property :network_id, String
end

class Hidden
  include DataMapper::Resource
  belongs_to :response, key: true

  property :id, Serial
end

class Status
  include DataMapper::Resource
  belongs_to :response, key: true

  property :id, Serial
  property :invited, Boolean, default: false
end

DataMapper.finalize
DataMapper.auto_upgrade!

time_now = Time.now.to_i

key = ENV['typeform_key']
uid = ENV['typeform_uid']
completed = true
typeform_url = "https://api.typeform.com/v0/form/#{uid}"

response = JSON.parse(HTTParty.get(typeform_url, query: {key: key, completed: completed}).body)

response['questions'].each do |question|
  Question.first_or_create(q_id: question['id'], question: question['question'])
end

response['responses'].each do |response|
  hidden = response.delete('hidden')
  answers = response.delete('answers')
  response['answers'] = []
  response['status'] = {}
  answers.each do |q_id, answer|
    response['answers'].push({ q_id: q_id, answer: answer })
  end
  response['r_id'] = response.delete('id')
  Response.first_or_create(response)
end

token = ENV['slack_token']
channels = ENV['slack_channels'].split(',').map(&:strip)

set_active = 'true'
slack_url = "https://#{ENV['slack_team']}.slack.com/api/users.admin.invite?t=#{time_now}"

Response.all(Response.status.invited => false).each do |response|
  first_name = response.answers.first(:q_id => ENV['typeform_first_name']).answer
  email = response.answers.first(:q_id => ENV['typeform_email']).answer
  r = HTTParty.post(slack_url, query: {email: email, channels: channels.join(','), first_name: first_name, token: token, set_active: set_active})
  puts "#{email} - #{r}"
  response.status.invited = true
  response.status.save
  sleep 2 # so we don't get rate limited
end
