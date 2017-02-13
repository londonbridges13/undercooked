require 'doorkeeper/grape/helpers'

module API
  module V2
    class Resources < Grape::API
      helpers Doorkeeper::Grape::Helpers
      before do
        doorkeeper_authorize!
      end
      format :json
      helpers ResourcesHelper

      resource :resources do
        namespace 'display_resource' do
          desc "Query a Resource"
          post do
            id = params[:uarticle]
            article = Article.find_by_id(id)
            resource = article.resource
            present resource

          end
        end
      end

      resource :resources do
        namespace 'display_resources' do
          desc "Query all Resource"
          post do
            resources = Resource.all
            present resources
          end
        end
      end

      resource :resources do
        namespace 'get_resource_info' do
          desc "Query a Resource"
          post do
            resource_id = params[:resource_id]
            resource = Resource.find_by_id(resource_id)
            present resource
          end
        end
      end

      resource :resources do
        namespace 'display_resource_articles' do
          desc "Query Resource's Articles"
          post do
            resource_id = params[:resource_id]
            resource = Resource.find_by_id(resource_id)
            present resource.articles
          end
        end
      end


      resource :resources do
        namespace 'test_resource' do
          desc "Query a Resource"
          post do
            resource_id = params[:resource_id]
            resource = Resource.find_by_id(resource_id)

            check_resource(resource)

          end
        end
      end


      resource :resources do
        namespace 'get_resource_topics' do
          desc "Query Resource's Topics"
          post do
            id = params[:resource_id]
            resource = Resource.find_by_id(id)
            present resource.topics
          end
        end
      end

      resource :resources do
        namespace 'get_topic_resources' do
          desc "Query Resource's Topics"
          post do
            id = params[:utopic]
            topic = Topic.find_by_id(id)
            present topic.resources
          end
        end
      end

      resource :resources do
        namespace 'update_title_desc' do
          desc "Update Desc and Title of an Article"
          post do
            id = params[:resource_id]
            title = params[:title]
            desc = params[:desc]

            resource = Resource.find_by_id(id)
            resource.desc = desc
            resource.title = title
            resource.save
            present resource
          end
        end
      end


      resource :resources do
        namespace 'link_to_topics' do
          desc "Connect Resource to Topics"
          post do
            resource_id = params[:resource_id]
            resource = Resource.find_by_id(resource_id)

            topics = params[:topics]

            resource.topics.delete_all

            topics.each do |t|
              topic = Topic.find_or_create_by(title: t)
              unless resource.topics.include? topic
                resource.topics.push(topic)
              end
            end
            present topics

          end
        end
      end



    end
  end
end
