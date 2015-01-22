require 'rubygems'
require 'nokogiri'
require 'pp'
require 'open-uri'
require 'json'
   
#page = Nokogiri::HTML(open("http://en.wikipedia.org/"))   
def parseFeatureHTML(file) 
	page = Nokogiri::HTML(open("reports/#{file}")) 
	body = page.at_css("body")
	total_content = body.at_css("p#totals").content
	duration_content = body.at_css("p#duration").content

	scripttag = page.search('//script[contains(text(),"Finished")]/text()').text
	scripttaglast = page.search('//script[contains(text(),"scenarios")]/text()').text
	return page.css("div.feature"), total_content, duration_content, scripttag.scan(/"([^"]*)"/), scripttaglast.scan(/"([^"]*)"/)
end

html_doc = Nokogiri::HTML(open("reports/report8.html"))
html_body_doc = html_doc.at_css("body")
cucumber_header = html_body_doc.at_css("div#cucumber-header")
totals = html_doc.at_css("p#totals")
durations = html_doc.at_css("p#duration")

new_paragraph1 = Nokogiri::XML::Node.new("p", html_doc)
new_paragraph3 = Nokogiri::XML::Node.new("p", html_doc)
new_paragraph2 = Nokogiri::XML::Node.new("strong", html_doc)
durations.content = "Finished in "

html=""
htmlFinal=""

htmlInitial = %Q{
<!DOCTYPE html>
<html lang="en">
  <head></head>
  <body>
	<div class="cucumber">
	</div>
  </body>
</html>
}

_total = ''
_duration = ''
_scripttag = ''
_scripttaglast = ''
doc = Nokogiri::HTML(htmlInitial)
body = doc.at_css("body")
head_org = doc.at_css("head")
head = html_doc.at_css("head")
cucu_id = body.at_css("div.cucumber")

cucu_id << cucumber_header

index = 0
_scenario=0
_step=0
_scenario_failed=0
_scenario_passed=0
_steps_failed=0
_steps_passed=0
_steps_skipped=0
_zero=0
_arrtime=[]

Dir.foreach('reports/') do |file|
  next if file == '.' or file == '..'
  html,_total, _duration, _scripttag, _scripttaglast = parseFeatureHTML(file)
  cucu_id << html 
  temptimeVal = _scripttag[0][0]
  tempval = _scripttaglast[0][0]
  _steps = ((tempval.split("<br />").last).split("steps").last).tr(')(','')
  _steps_array = _steps.split(",").map(&:lstrip).reduce([]) { |arr, item|
		id=item.split(" ").first
		key=item.split(" ").last
		arr << key << id
  }
  _tempTimeHtml = ((temptimeVal.split("<strong>").last).split("seconds").first).split(" ")[0]
  _arrtime.push(_tempTimeHtml)
  _steps_hash = Hash[*_steps_array]
  
  _steps_failed += (_steps.tr(',','').include? "failed")?((_steps_hash["failed"]).to_i):(_zero)
  _steps_passed += (_steps.tr(',','').include? "passed")?((_steps_hash["passed"]).to_i):(_zero)
  _steps_skipped += (_steps.tr(',','').include? "skipped")?((_steps_hash["skipped"]).to_i):(_zero)

  _scenario_data = ((tempval.split("<br />").first).split("scenarios").last).tr(')(','').tr(',','')
  _scenario_failed += (_scenario_data.split("failed").first).split.join(" ").to_i
  _scenario_passed += ((_scenario_data.split("failed").last).split("passed").first).split.join(" ").to_i

  _scenario += ((tempval.split("<br />").first).split("scenarios").first).split.join(" ").to_i
  _step += ((tempval.split("<br />").last).split("steps").first).split.join(" ").to_i
end
head_org << head

_sumMin = _arrtime.map{ |val|
	_min = val.split("m").first
}.map(&:to_f).reduce(:+)

_sumSecond = _arrtime.map{ |val|
	_hour = (val.split("m").last).split("s").first
}.map(&:to_f).reduce(:+)

new_paragraph1.content = "#{_step}  Steps (#{_steps_failed} failed,#{_steps_skipped} skipped, #{_steps_passed} passed)"
new_paragraph2.content = " #{_sumMin}m#{_sumSecond}s"

_totals = doc.at_css("p#totals")
_durations = doc.at_css("p#duration")

_totals.content= "#{_scenario} scenarios (#{_scenario_failed} failed, #{_scenario_passed} passed) "
_totals << new_paragraph1
_durations << new_paragraph2

puts doc
