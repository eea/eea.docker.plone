vcl 4.0;

import directors;

backend instance1 {
    .host = "instance1";
    .port = "8080";
    .probe = {
        .url = "/";
        .interval = 10s;
        .window = 5;
        .threshold = 2;
    }
}

backend instance2 {
    .host = "instance2";
    .port = "8080";
    .probe = {
        .url = "/";
        .interval = 10s;
        .window = 5;
        .threshold = 2;
    }
}

sub vcl_init {
    new site = directors.round_robin();
    site.add_backend(instance1);
    site.add_backend(instance2);
}
