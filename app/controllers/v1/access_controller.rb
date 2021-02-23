module V1
  # Answers the question.  Can the given agent view the given resource.
  # e.g. GET /v1/authorize/:level/:druid/:file_name?agent[user_key]=jcoyne85&agent[stanford]=true
  # Where ':level' is 'read', 'download', or 'access'
  class AccessController < ApplicationController
    def show
      ident = ResourceIdentifier.new(druid: params[:druid], file_name: params[:file_name])
      agent = Agent.new
      access = AccessService.new(identifier: ident, level: params[:level], agent: agent)
      render json: { authorized: access.authorized? }
    end
  end
end
