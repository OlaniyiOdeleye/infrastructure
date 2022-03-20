output "self_link" {
  description = "The ssl self link"
  value       = google_compute_managed_ssl_certificate.this.self_link
}


output "website_url" {
  description = "URL of the website"
  value       = module.static_website.website_url
}

output "website_bucket_name" {
  description = "Name of the website Bucket"
  value       = module.static_website.website_bucket_name
}
