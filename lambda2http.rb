require 'sinatra'
require 'active_support/all'

require 'aws-sdk'

$stdout.sync = true

post "/:function" do
  access_key = request.env["HTTP_AWS_ACCESS_KEY"] || ENV['AWS_ACCESS_KEY']
  secret_access_key = request.env["HTTP_AWS_SECRET_KEY"] || ENV['AWS_SECRET_KEY']
  region = request.env["HTTP_AWS_REGION"] || ENV['AWS_REGION']
  account_id = request.env["HTTP_AWS_ACCOUNT_ID"] || ENV["AWS_ACCOUNT_ID"]

  client_context_json = {}.to_json
  client_context_json_base64 = Base64.encode64(client_context_json)

  body = request.body.read

  lambda = Aws::Lambda::Client.new(
    access_key_id: access_key,
    secret_access_key: secret_access_key,
    region: region
  )

  response = lambda.invoke(
    function_name: "arn:aws:lambda:#{region}:#{account_id}:function:#{params[:function]}",
    invocation_type: "RequestResponse",
    log_type: "None",
    client_context: client_context_json_base64,
    payload: body
  )

  if response.class == Aws::PageableResponse
    response.payload
  else
    halt 500, "error"
  end
end
