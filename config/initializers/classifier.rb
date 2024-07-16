# Let's set up our redis backend
redis_backend = ClassifierReborn::BayesRedisBackend.new url: ENV.fetch('REDIS_URL') if ENV['REDIS_URL']
# Set up the classifier for ham and spam
Rails.application.config.classifier = ClassifierReborn::Bayes.new 'ham', 'spam', { backend: redis_backend }.compact
