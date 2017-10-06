challenge
=========

A sample Crystal *Kemal* web application, utilising JSON Web Tokens (JWTs) for User Authentication.

## To Run:

To run this sample app, you first need to create a SQL database to contain the sample data.  Create a MySQL database and user with permissions for reads and writes etc.

The quickest way to do scaffold the database is to use the database migration tool, [https://github.com/juanedi/micrate](Micrate.)

To install the Micrate standalone, run:

~~~ bash
$ brew tap juanedi/micrate
$ brew install micrate
~~~

After creating this database and installing Micrate, we need to tell Micrate to connect to the correct database.  Set the following as an environment variable:

~~~ bash
DATABASE_URL="mysql://[DB_USER]:[DB_PASS]@localhost:3306/[DB_NAME]"
~~~

Then from your working directory, run:

~~~ bash
micrate create challenge
~~~

This will have created a file in `/db/migrations` titled `20170929011555_create_challenge.sql` or similar.  Open up that file and have it reflect the following:

~~~ sql
-- +micrate Up
CREATE TABLE challenges (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255),
  details TEXT,
  posted_by VARCHAR(255),
  created_at TIMESTAMP NULL,
  updated_at TIMESTAMP NULL
);

-- +micrate Down
DROP TABLE IF EXISTS challenges;
~~~

You can now run the `micrate up` command to structure the database.

Now, run the `shards install` command from within the application directory, and execute:

  crystal run src/challenger.cr


## Contributing

1. Fork it ( https://github.com/rbnpercy/challenge/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [rbnpercy](https://github.com/rbnpercy) Robin Percy - creator, maintainer
