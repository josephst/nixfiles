{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.networking) domain hostName;
  fqdn = "${hostName}.${domain}";
  format = pkgs.formats.yaml {};

  # TODO: configure with nix (instead of writing yaml)
  httpcheckConfig = {
    update_every = 1;
    autodetection_retry = 0;
    priority = 70000;

    jobs = [
      {
        name = "sabnzbd";
        url = "https://sabnzbd.${fqdn}";
      }
    ];
  };
  configFile = format.generate "httpcheck.conf" httpcheckConfig;
in {
  services.netdata = {
    enable = true;
    configDir = {
      "go.d/httpcheck.conf" = pkgs.writeText "httpcheck.conf" ''
          update_every        : 1
          autodetection_retry : 0
          priority            : 70000

          jobs:
           - name: sabnzbd
             url: https://sabnzbd.${fqdn}
      '';
    };
  };

  # environment.etc."netdata/go.d/httpcheck.conf".text = ''
    # netdata go.d.plugin configuration for httpcheck
    #
    # This file is in YAML format. Generally the format is:
    #
    # name: value
    #
    # There are 2 sections:
    #  - GLOBAL
    #  - JOBS
    #
    #
    # [ GLOBAL ]
    # These variables set the defaults for all JOBs, however each JOB may define its own, overriding the defaults.
    #
    # The GLOBAL section format:
    # param1: value1
    # param2: value2
    #
    # Currently supported global parameters:
    #  - update_every
    #    Data collection frequency in seconds. Default: 1.
    #
    #  - autodetection_retry
    #    Re-check interval in seconds. Attempts to start the job are made once every interval.
    #    Zero means not to schedule re-check. Default: 0.
    #
    #  - priority
    #    Priority is the relative priority of the charts as rendered on the web page,
    #    lower numbers make the charts appear before the ones with higher numbers. Default: 70000.
    #
    #
    # [ JOBS ]
    # JOBS allow you to collect values from multiple sources.
    # Each source will have its own set of charts.
    #
    # IMPORTANT:
    #  - Parameter 'name' is mandatory.
    #  - Jobs with the same name are mutually exclusive. Only one of them will be allowed running at any time.
    #
    # This allows autodetection to try several alternatives and pick the one that works.
    # Any number of jobs is supported.
    #
    # The JOBS section format:
    #
    # jobs:
    #   - name: job1
    #     param1: value1
    #     param2: value2
    #
    #   - name: job2
    #     param1: value1
    #     param2: value2
    #
    #   - name: job2
    #     param1: value1
    #
    #
    # [ List of JOB specific parameters ]:
    #  - url
    #    Server URL.
    #    Syntax:
    #      url: http://localhost:80
    #
    #  - status_accepted
    #    HTTP accepted response statuses. Anything else will result in 'bad status' in the status chart.
    #    Syntax:
    #      status_accepted: [200, 300, 400]
    #
    #  - response_match
    #    If the status code is accepted, the content of the response will be searched for this regex.
    #    Syntax:
    #      response_match: pattern   # Pattern syntax: golang regular expression. See https://pkg.go.dev/regexp/syntax
    #
    #  - username
    #    Username for basic HTTP authentication.
    #    Syntax:
    #      username: tony
    #
    #  - password
    #    Password for basic HTTP authentication.
    #    Syntax:
    #      password: stark
    #
    #  - proxy_url
    #    Proxy URL.
    #    Syntax:
    #      proxy_url: http://localhost:3128
    #
    #  - proxy_username
    #    Username for proxy basic HTTP authentication.
    #    Syntax:
    #      username: bruce
    #
    #  - proxy_password
    #    Password for proxy basic HTTP authentication.
    #    Syntax:
    #      username: wayne
    #
    #  - timeout
    #    HTTP response timeout.
    #    Syntax:
    #      timeout: 1
    #
    #  - method
    #    HTTP request method.
    #    Syntax:
    #      method: GET
    #
    #  - body
    #    HTTP request method.
    #    Syntax:
    #      body: '{fake: data}'
    #
    #  - headers
    #    HTTP request headers.
    #    Syntax:
    #      headers:
    #        X-API-Key: key
    #
    #  - not_follow_redirects
    #    Whether to not follow redirects from the server.
    #    Syntax:
    #      not_follow_redirects: yes/no
    #
    #  - tls_skip_verify
    #    Whether to skip verifying server's certificate chain and hostname.
    #    Syntax:
    #      tls_skip_verify: yes/no
    #
    #
    #  - tls_ca
    #    Certificate authority that client use when verifying server certificates.
    #    Syntax:
    #      tls_ca: path/to/ca.pem
    #
    #  - tls_cert
    #    Client tls certificate.
    #    Syntax:
    #      tls_cert: path/to/cert.pem
    #
    #  - tls_key
    #    Client tls key.
    #    Syntax:
    #      tls_key: path/to/key.pem
    #
    #
    # [ JOB defaults ]:
    #  status_accepted       : [200]
    #  timeout               : 1
    #  method                : GET
    #  not_follow_redirects  : no
    #  tls_skip_verify       : no
    #  update_every          : 5
    #
    #
    # [ JOB mandatory parameters ]:
    #  - name
    #  - url
    #
    # ------------------------------------------------MODULE-CONFIGURATION--------------------------------------------------

    # update_every        : 1
    # autodetection_retry : 0
    # priority            : 70000

    # jobs:
    #  - name: jira
    #    url: https://jira.localdomain/

    #  - name: cool_website
    #    url: http://cool.website:8080/home
    #    status_accepted: [200, 204]
    #    response_match: <title>My cool website!<\/title>
    #    timeout: 2
  # '';
}
