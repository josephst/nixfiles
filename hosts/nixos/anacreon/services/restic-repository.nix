{
  age.secrets = {
    "restic/paperless-repository".file = ../secrets/restic/paperless-repository.age;
    "restic/paperless-password".file = ../secrets/restic/paperless-password.age;
    "restic/paperless.env".file = ../secrets/restic/paperless.env.age;
  };
}
