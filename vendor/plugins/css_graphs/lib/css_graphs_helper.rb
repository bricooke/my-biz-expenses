module CssGraphsHelper
  
  # Makes a vertical bar graph.
  #
  #  bar_graph [["Stout", 10], ["IPA", 80], ["Pale Ale", 50], ["Milkshake", 30]]
  #
  # NOTE: Updated to take an array instead of forcing you to use *array.
  # NOTE: Normalizes data to fit in the viewable area instead of being fixed to 100.

  def bar_graph(data=[])
    width = 378
    height = 150
    colors = %w(#ce494a #efba29 #efe708 #5a7dd6 #73a25a)
    floor_cutoff = 24 # Pixels beneath which values will not be drawn in graph
    data_max = data.inject(0) { |memo, array| array.last > memo ? array.last : memo }


    html = <<-"HTML"
    <style>
      #vertgraph {    				
          width: #{width}px; 
          height: #{height}px; 
          position: relative; 
          background-color: #eeeeee;
          border: 4px solid #999999;
          font-family: "Lucida Grande", Verdana, Arial;
      }

      #vertgraph dl dd {
        position: absolute;
        width: 28px;
        height: 103px;
        bottom: 34px;
        padding: 0 !important;
        margin: 0 !important;
        background-image: url('/images/css_graphs/colorbar.jpg') no-repeat !important;
        text-align: center;
        font-weight: bold;
        color: white;
        line-height: 1.5em;
      }

      #vertgraph dl dt {
        position: absolute;
        width: 48px;
        height: 25px;
        bottom: 0px;
        padding: 0 !important;
        margin: 0 !important;
        text-align: center;
        color: #444444;
        font-size: 0.8em;
      }
    HTML

    bar_offset = 24
    bar_increment = 75
    bar_image_offset = 28

    data.each_with_index do |d, index|
      bar_left = bar_offset + (bar_increment * index)
      label_left = bar_left - 10
      background_offset = bar_image_offset * index

      html += <<-HTML
        #vertgraph dl dd.#{d[0].to_s.downcase} { left: #{bar_left}px; background-color: #{colors[index]}; background-position: -#{background_offset}px bottom !important; }
        #vertgraph dl dt.#{d[0].to_s.downcase} { left: #{label_left}px; background-position: -#{background_offset}px bottom !important; }
      HTML
    end

    html += <<-"HTML"
      </style>
      <div id="vertgraph">
        <dl>
    HTML

    data.each_with_index do |d, index|
      scaled_value = scale_graph_value(d.last, data_max, 100)
      html += <<-"HTML"
        <dt class="#{d.first.to_s.downcase}">#{d[0].to_s.humanize}</dt>
        <dd class="#{d.first.to_s.downcase}" style="height: #{scaled_value}px;" title="#{d.last}">#{scaled_value < floor_cutoff ? '' : d.last}</dt>
      HTML
    end

    html += <<-"HTML"
        </dl>
      </div>
    HTML

    html
  end
  
  def add_percent(number)
    return "#{number}%"
  end

  # Make a horizontal graph that only shows percentages.
  #
  # The label will be set as the title of the bar element.
  #
  #  horizontal_bar_graph [["Stout", 10], ["IPA", 80], ["Pale Ale", 50], ["Milkshake", 30]]
  # 
  # NOTE: Updated to take an array instead of forcing you to use *array.
  # NOTE: Updated to take options for colors and to normalize
  # NOTE: Updated to take a method to format the numbers shown
  def horizontal_bar_graph(data, user_options = {}, number_formatter = method(:add_percent))
    options = {:show_names => false, 
               :normalize => false, 
               :width => "240px;",
               :bar_color => "#B1D632", 
               :text_color => "#333", 
               :background_color => nil}.merge(user_options)
               
    # figure out the max
    if options[:normalize]
      data_max = data.inject(0) { |max, array| array.last > max ? array.last : max }
    else
      data_max = 100
    end
    
    background_color = "background-color: #{options[:background_color]};" if options[:background_color]
    
    html = <<-"HTML"
      <style>
      /* Basic Bar Graph */
      .graph { 
        position: relative; /* IE is dumb */
        width: #{options[:width]}; 
        border: 1px solid #{options[:bar_color]}; 
        padding: 2px; 
        margin-bottom: .5em;					
        #{background_color}
        color: #{options[:text_color]};
      }
      .graph .bar { 
        display: block;	
        position: relative;
        background: #{options[:bar_color]}; 
        text-align: center; 
        color: #{options[:text_color]}; 
        height: 2em; 
        line-height: 2em;									
      }
      .graph .bar span { position: absolute; left: 1em; } /* This extra markup is necessary because IE does not want to follow the rules for overflow: visible */	 
      </style>
    HTML

    data.each do |d|
      name = "#{d[0].to_s.humanize}<br/>" if options[:show_names]
      html += <<-"HTML"
        <div class="graph">
          #{name}<strong class="bar" style="width: #{scale_graph_value(d[1], data_max, 100)}%;" title="#{d[0].to_s.humanize}"><span>#{number_formatter.call(d[1])}</span> </strong>
        </div>
      HTML
    end
    return html
  end

  # Makes a multi-colored bar graph with a bar down the middle, representing the value.
  #
  #  complex_bar_graph [["Stout", 10], ["IPA", 80], ["Pale Ale", 50], ["Milkshake", 30]]
  #  
  # NOTE: Updated to take an array instead of forcing you to use *array.
  # NOTE: Does not normalize data yet...TODO

  def complex_bar_graph(data)
    html = <<-"HTML"
      <style>
      /* Complex Bar Graph */
      div#complex_bar_graph dl { 
      	margin: 0; 
      	padding: 0;   
      	font-family: "Lucida Grande", Verdana, Arial;	
      }
      div#complex_bar_graph dt { 
      	position: relative; /* IE is dumb */
      	clear: both;
      	display: block; 
      	float: left; 
      	width: 104px; 
      	height: 20px; 
      	line-height: 20px;
      	margin-right: 17px;              
      	font-size: .75em; 
      	text-align: right; 
      }
      div#complex_bar_graph dd { 
      	position: relative; /* IE is dumb */
      	display: block;   
      	float: left;	 
      	width: 197px; 
      	height: 20px; 
      	margin: 0 0 15px; 
      	background: url("/images/css_graphs/g_colorbar.jpg"); 
      }
      * html div#complex_bar_graph dd { float: none; } /* IE is dumb; Quick IE hack, apply favorite filter methods for wider browser compatibility */

      div#complex_bar_graph dd div { 
      	position: relative; 
      	background: url("/images/css_graphs/g_colorbar2.jpg"); 
      	height: 20px; 
      	width: 75%; 
      	text-align:right; 
      }
      div#complex_bar_graph dd div strong { 
      	position: absolute; 
      	right: -5px; 
      	top: -2px; 
      	display: block; 
      	background: url("/images/css_graphs/g_marker.gif"); 
      	height: 24px; 
      	width: 9px; 
      	text-align: left;
      	text-indent: -9999px; 
      	overflow: hidden;
      }
      </style>
      <div id="complex_bar_graph">  
      <dl>
    HTML

    data.each do |d|
      html += <<-"HTML"
        <dt class="#{d[0].to_s.downcase}">#{d[0].to_s.humanize}</dt>
        <dd class="#{d[0].to_s.downcase}" title="#{d[1]}">
        <div style="width: #{d[1]}%;"><strong>#{d[1]}%</strong></div>
      </dd>
    HTML
    end

    html += "</dl>\n</div>"
    return html    
  end

  ##
  # Scale values within a +max+. The +max+ will usually be the height of the graph.

  def scale_graph_value(data_value, data_max, max)
    ((data_value.to_f / data_max.to_f) * max).round
  end
  
end
