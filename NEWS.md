<h1>PodcastIndex Database Dashboard 1.1.0</h1>

<h2>Bug Fixes</h2>

* Exclude records without an iTunes ID before executing the unique iTunes ID quality check to account for podcasts not submitted to iTunes
* Align dashboard content to the top of each page instead of the middle
* Disable cell word wrap in duplicate group table

<h2>Enhancements</h2>

* Add iTunes ID, content hash, and host to podcast record displays (both duplicate groups and quality checks)
* Display pre-processing notes for each data quality check when viewing the export of failed records
* Move export download link to bottom of the export display table
* Change coloring style of episode count and HTTP status code cells to the tile style instead of the entire cell background
* Display quality check processing time in quality check table
* Add new tab to render changelog

<h2>Infrastructure</h2>

* Source the data quality check export files directly from the versions in object storage which have been processed in the GitHub action script for performing the quality analysis

<h1>PodcastIndex Database Dashboard 1.0.0</h1>

This is the initial relaase of the PodcastIndex Dashboard!

<h2>Major changes</h2>

* Duplicates: Viewipodcast entry duplicate groups inside an interactive table, with drill-down functionality to view the flagged duplicate record metadata inside each group.
* Data Quality: View results of database quality assertions, with the ability to export the flagged records producing non-compliance for any rule that did not have all records pass the criteria.
* Additional pages with explanations of the duplicate analysis methods, motivation for creating the dashboard, and information on the technical stack making it possible.