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
        namespace 'get_new_articles' do
          desc "Get New Articles"
          post do
            search_for_articles
          end
        end
      end

      resource :articles do
        namespace 'new_article_count' do
          desc "Query New Articles"
          post do
            articles = Article.where(:publish_it => nil)#, with: Entity::V1::ArticlesEntity
            present articles.count
          end
        end
      end

      resource :articles do
        namespace 'accepted_articles' do
          desc "Query New Articles"
          post do
            articles = Article.where(:publish_it => true).shuffle#, with: Entity::V1::ArticlesEntity
            if articles.count > 0
              # Display Articles
              present articles #Article.order(title: :asc), with: Entity::V1::ArticlesEntity
            else
              # Grab New Content from Feed,
              present 0
              search_for_articles # edit in ArticlesHelper.rb
            end
          end
        end
      end

      resource :articles do
        namespace 'rejected_articles' do
          desc "Query New Articles"
          post do
            remove_old_unused_articles
            articles = Article.where(:publish_it => false).shuffle#, with: Entity::V1::ArticlesEntity
            if articles.count > 0
              # Display Articles
              present articles #Article.order(title: :asc), with: Entity::V1::ArticlesEntity
            else
              # Grab New Content from Feed,
              present 0
              search_for_articles # edit in ArticlesHelper.rb
            end
          end
        end
      end

      resource :articles do
        namespace 'accept_article' do
          desc "Set Publish = true"
          post do
            id = params[:uarticle]
            article = Article.find_by_id(id)
            article.publish_it = true
            article.save
            present article
          end
        end
      end

      resource :articles do
        namespace 'reject_article' do
          desc "Set Publish = false"
          post do
            id = params[:uarticle]
            article = Article.find_by_id(id)
            article.publish_it = false
            article.save
            present article
          end
        end
      end


      resource :articles do
        namespace 'get_article_info' do
          desc "Self"
          post do
            id = params[:uarticle].to_i
            article = Article.find_by_id(id)
            present article
          end
        end
      end


      resource :articles do
        namespace 'get_article_resource' do
          desc "Self"
          post do
            id = params[:uarticle].to_i
            article = Article.find_by_id(id)
            present article.resource
          end
        end
      end

      resource :articles do
        namespace 'get_article_tags' do
          desc "Self"
          post do
            id = params[:uarticle].to_i
            article = Article.find_by_id(id)
            present article.tags
          end
        end
      end

      resource :articles do
        namespace 'update_title_desc' do
          desc "Update Desc and Title of an Article"
          post do
            id = params[:uarticle]
            title = params[:title]
            desc = params[:desc]

            article = Article.find_by_id(id)
            article.desc = desc
            article.title = title
            article.save
            present article
          end
        end
      end

      resource :products do
        namespace 'update_title_desc' do
          desc "Update Desc and Title of an Article"
          post do
            id = params[:uproduct]
            title = params[:title]
            desc = params[:desc]

            product = Product.find_by_id(id)
            product.description = desc
            product.title = title
            product.save
            present product
          end
        end
      end

      resource :topics do
        namespace 'article_topics' do
          desc "Query Article's Topics"
          post do
            id = params[:uarticle]
            article = Article.find_by_id(id)
            present article.topics
          end
        end
      end

      resource :articles do
        namespace 'update_topics' do
          desc "Sets Article's Topics"
          post do
            id = params[:uarticle]
            topics = params[:topics]

            article = Article.find_by_id(id)
            article.topics.delete_all

            topics.each do |t|
              topic = Topic.find_or_create_by(title: t)
              unless article.topics.include? topic
                article.topics.push(topic)
              end
            end
            present topics
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



      resource :users do
        namespace 'user_count' do
          desc ""
          post do
            users_count = User.all.count#, with: Entity::V1::ArticlesEntity
            present users_count
          end
        end
      end

      resource :products do
        namespace 'product_count' do
          desc ""
          post do
            product_count = Product.all.count#, with: Entity::V1::ArticlesEntity
            present product_count
          end
        end
      end

      resource :products do
        namespace 'display_products' do
          desc ""
          post do
            products = Product.all#, with: Entity::V1::ArticlesEntity
            present products
          end
        end
      end

      resource :tags do
        namespace 'display_tags' do
          desc ""
          post do
            tags = Tag.all#, with: Entity::V1::ArticlesEntity
            present tags
          end
        end
      end

      resource :tags do
        namespace 'count_tag' do
          desc ""
          post do
            id = params[:utag]
            tag = Tag.find_by_id(id)#, with: Entity::V1::ArticlesEntity
            count = tag.articles.count + tag.topics.count + tag.resources.count + tag.products.count
            present count
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
            if article.tags.count == 0

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

      resource :articles do
        namespace 'update_tags' do
          desc "Update Tags of an Article"
          post do
            id = params[:uarticle]
            tags = params[:tags]#.downcase

            article = Article.find_by_id(id)
            article.tags.delete_all
            array_of_tags = tags

            array_of_tags.each do |t|
              tag = Tag.find_or_create_by(title: t)
              unless article.tags.include? tag
                article.tags.push(tag)
              end
            end
            present article
          end
        end
      end


      resource :topics do
        namespace 'count_recent_articles' do
          desc "Counts the Topic's recent articles"
          post do
            id = params[:utopic]
            topic = Topic.find_by_id(id)
            two_days_ago = Time.now - 3.days
            article_count = topic.articles.where('article_date > ?', two_days_ago).count

            present article_count
          end
        end
      end

    end
  end
end
