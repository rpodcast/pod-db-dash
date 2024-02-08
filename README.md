## Dev Notes

Compile the Shiny app to webassembly:

```r
shinylive::export(appdir = "app", destdir = "docs")
```

Testing the app executiong

```r
httpuv::runStaticServer("docs")
```