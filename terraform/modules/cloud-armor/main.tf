#------------------------------------
# Security Policies for Cloud Armor
#-------------------------------------
resource "google_compute_security_policy" "policy" {
  name = "owasp-top-ten"

  rule {
    action   = "deny(403)"
    priority = "1000"
    match {
      expr {
        expression = <<EOF
        evaluatePreconfiguredExpr('xss-stable', ['owasp-crs-v030001-id941340-xss',
          'owasp-crs-v030001-id941130-xss',
          'owasp-crs-v030001-id941170-xss',
          'owasp-crs-v030001-id941330-xss',
        ]
        )
        EOF
      }
    }
    description = "Prevent cross site scripting attacks"
    preview     = true
  }

  rule {
    action   = "deny(403)"
    priority = "2000"
    match {
      expr {
        expression = <<EOF
        evaluatePreconfiguredExpr('sqli-stable', ['owasp-crs-v030001-id942110-sqli',
          'owasp-crs-v030001-id942120-sqli',
          'owasp-crs-v030001-id942150-sqli',
          'owasp-crs-v030001-id942180-sqli',
          'owasp-crs-v030001-id942200-sqli',
          'owasp-crs-v030001-id942210-sqli',
          'owasp-crs-v030001-id942260-sqli',
          'owasp-crs-v030001-id942300-sqli',
          'owasp-crs-v030001-id942310-sqli',
          'owasp-crs-v030001-id942330-sqli',
          'owasp-crs-v030001-id942340-sqli',
          'owasp-crs-v030001-id942380-sqli',
          'owasp-crs-v030001-id942390-sqli',
          'owasp-crs-v030001-id942400-sqli',
          'owasp-crs-v030001-id942410-sqli',
          'owasp-crs-v030001-id942430-sqli',
          'owasp-crs-v030001-id942440-sqli',
          'owasp-crs-v030001-id942450-sqli',
          'owasp-crs-v030001-id942251-sqli',
          'owasp-crs-v030001-id942420-sqli',
          'owasp-crs-v030001-id942431-sqli',
          'owasp-crs-v030001-id942460-sqli',
          'owasp-crs-v030001-id942421-sqli',
          'owasp-crs-v030001-id942432-sqli',
          'owasp-crs-v030001-id942190-sqli']
        )
        EOF
      }
    }
    description = "Prevent sql injection attacks"
  }

  rule {
    action   = "deny(403)"
    priority = "3000"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('rce-stable') && evaluatePreconfiguredExpr('rfi-stable')"
      }
    }
    description = "Prevent remote code execution"
  }

  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }

}
