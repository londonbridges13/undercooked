module Entity
  module V1
    class ArticlesEntity < Grape::Entity
      expose :id, :title, :article_url, :article_image_url, :desc, :resource_type, :article_date,
      :publish_it, :image, :display_topic
    end
  end
end
