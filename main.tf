locals {
  // Add SRE Team Members Here
  sitereliability_engineers = [
    {
      username    = "dhart"
      fullname    = "Dan Hart"
      gpg_pub_key = "public_gpg_keys/dhart.gpg"
    },
    {
      username    = "userone"
      fullname    = "User One"
      gpg_pub_key = "public_gpg_keys/userone.gpg"
    }
  ]

  // Add Frontend Engineering Team Members Here
  frontend_engineers = [
    {
      username    = "usertwo"
      fullname    = "User Two"
      gpg_pub_key = "public_gpg_keys/userone.gpg"
    },
    {
      username    = "userthree"
      fullname    = "User Three"
      gpg_pub_key = "public_gpg_keys/userone.gpg"
    },
    {
      username    = "userfour"
      fullname    = "User Four"
      gpg_pub_key = "public_gpg_keys/userone.gpg"
    }
  ]

  // Add Backend Engineering Team Members Here
  backend_engineers = [
    {
      username    = "userfive"
      fullname    = "User Five"
      gpg_pub_key = "public_gpg_keys/userone.gpg"
    }
  ]
}
