.PHONY: all clean

all:
	Rscript -e "rmarkdown::render('README.Rmd', output_file = 'README.md', encoding = 'UTF-8', output_options = list(html_preview = FALSE))"

clean:
	$(RM) README.md README.html README.knit.md README.utf8.md
