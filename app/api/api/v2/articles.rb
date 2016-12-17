require 'doorkeeper/grape/helpers'
require 'rubygems'
require 'engtagger'

module API
  module V2
    class Articles < Grape::API

      helpers Doorkeeper::Grape::Helpers
      before do
        doorkeeper_authorize!
      end
      format :json
      helpers ArticlesHelper

      resource :articles do
        namespace 'new_articles' do
          desc "Query New Articles"
          post do
            articles = Article.where(:publish_it => nil).shuffle#, with: Entity::V1::ArticlesEntity
            if articles.count > 0
              # Display Articles
              present articles #Article.order(title: :asc), with: Entity::V1::ArticlesEntity
            else
              # Grab New Content from Feed,
              search_for_articles # edit in ArticlesHelper.rb
            end
          end
        end
      end

      resource :articles do
        namespace 'add_article_topics' do
          desc "Query Articles based on User's Topics"
          post do
            # Get the array of topic ids
            article_id = params[:article_id].to_i
            article = Article.find_by_id(article_id)
            topics = params[:topics] #convert into array of integars
            array_of_topics = topics.split(",").map(&:to_i)
            array_of_topics.each do |t|
              a_topic = Topic.find_by_id(t)
              unless article.topics.include? a_topic or a_topic == nil
                # Don't want to add a topic that already exists
                article.topics.push(a_topic)
                present "Successfully added topics"
                # present article

              end
            end
          end
        end
      end

      resource :topics do
        namespace 'display_topics' do
          desc "Query All Topics"
          post do
            topics = Topic.all#, with: Entity::V1::ArticlesEntity
            present topics
          end
        end
      end

      resource :tags do
        namespace 'suggest_tags' do
          desc "Suggests tags for Article, based on Description"
          post do
            desc = params[:description].downcase
            article = Article.find_by_id(params[:article_id].to_i)
            title = article.title.downcase
            tgr = EngTagger.new
            tagged = tgr.add_tags(desc)
            title_tags = tgr.add_tags(title)
            noun_tags = tgr.get_nouns(tagged)
            adj_tags = tgr.get_adjectives(tagged)
            all_tags = []
            all_tags.push(title)
            noun_tags.each do |n|
              # take out string and add it to array
              unless all_tags.include? n.first.downcase
                all_tags.push(n.first)
              end
            end
            adj_tags.each do |a|
              # take out string and add it to array
              unless all_tags.include? a.first.downcase
                all_tags.push(a.first)
              end
            end
            # Find or Create tag, then link article to each tag
            all_tags.each do |t|
              tag = Tag.find_or_create_by(title: t)
              unless tag.articles.include? article
                # Add tag
                tag.articles.push(article)
              end
            end
            present all_tags
          end
        end
      end

    end
  end
end
