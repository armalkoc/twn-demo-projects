helm install -f values/redis-values.yaml rediscart redis-chart

helm install -f values/ad-service-values.yaml adservice microservices-helm-chart
helm install -f values/cart-service-values.yaml cartservice microservices-helm-chart
helm install -f values/checkout-service-values.yaml checkoutservice microservices-helm-chart
helm install -f values/currency-service-values.yaml currencyservice microservices-helm-chart
helm install -f values/email-service-values.yaml emailservice microservices-helm-chart
helm install -f values/frontend-values.yaml frontendservice microservices-helm-chart
helm install -f values/payment-service-values.yaml paymentservice microservices-helm-chart
helm install -f values/productcatalog-service-values.yaml productcatalogservice microservices-helm-chart
helm install -f values/recommendation-service-values.yaml recommendationservice microservices-helm-chart
helm install -f values/shipping-service-values.yaml shippingservice microservices-helm-chart