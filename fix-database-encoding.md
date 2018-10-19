## Fixing mixed database encodings of Latin1 to UTF8 in OJS

From https://www.whitesmith.co/blog/latin1-to-utf8/, with thanks to Alec Smecher for the suggestion.

This assumes the incorrectly encoded database exists (called ojs_latin in this example). As always, **make sure you have backups**!

### Log into your future database host to create a new database with an UTF-8 charset named ojs

```
$ mysql -h 127.0.0.1 -u USERNAME -pPASSWORD
mysql> CREATE DATABASE `ojs` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
exit
```

### Flush the current database schema on the future host, replacing all CHARSET=latin1 occurrences along the way

```
mysqldump --column-statistics=0 -h 127.0.0.1 -u USERNAME -pPASSWORD ojs_latin --no-data --skip-set-charset --default-character-set=latin1 \
| sed 's/CHARSET=latin1/CHARSET=utf8/g' \
| mysql -h 127.0.0.1 -u USERNAME -pPASSWORD ojs --default-character-set=utf8
```

### Flush the current database data on the future host

```
mysqldump --column-statistics=0 -h 127.0.0.1 -u USERNAME -pPASSWORD --no-create-db --no-create-info --skip-set-charset --default-character-set=latin1 ojs_latin \
| mysql -h 127.0.0.1 -u USERNAME -pPASSWORD ojs --default-character-set=utf8
```

### Notes

If you receive a warning about the article search tables, you can safely delete the contents of article_search_keyword_list, article_search_object_keywords, and article_search_objects before upgrading – these tables contain the full-text search index and can be re-generated afterwards by running `php tools/rebuildSearchIndex.php`.

OJS 2:
```
DELETE FROM article_search_keyword_list;
DELETE FROM article_search_object_keywords;
DELETE FROM article_search_objects;
```

OJS 3:
```
DELETE FROM submission_search_keyword_list;
DELETE FROM submission_search_object_keywords;
DELETE FROM submission_search_objects;
```

If not set, set `charset = utf8` in `config.inc.php` after fixing the database.
