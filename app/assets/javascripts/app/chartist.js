(function($){

  function get_wallet_chart(){
    $(".wallet-chart").each(function(i,e){
      item = e
      wallet_id = $(e).attr('data-walletId');
      interval = $(e).attr('data-interval');
      $.ajax({ type: "GET", url: "/finances/charts/wallet_balance.json?wallet_id=" + wallet_id + "&interval_period=" + interval, cache: false }).success(function(chart_data){
        id = '#' + $(e).attr('id');
        keys = Object.keys(chart_data);
        values = keys.map(function(v) { return parseInt(chart_data[v]); });
        min = Math.min.apply( Math, values );
        max = Math.max.apply( Math, values );
        range = max - min;
        if (range == 0){
          range = 100
        }
        new Chartist.Line(id, {
          labels: keys,
          series: [
            values
          ]
        }, {
          low:min - range/10, // TODO: get highest and lowest from data, then add/substract some percentage of their range? Yep.
          high:max + range/10, // TODO: get highest and lowest from data, then add/substract some percentage of their range? Yep.
          lineSmooth: Chartist.Interpolation.none({
            // was cardinal. Should it be?
            // we should also variably select between cardinal and simple, dependent upon... the complexity of the data?
            // or not at all. I dunno.
          }),
          showPoint: true,
          showArea: true,
          axisY: {
            //showLabel: false, // if we want to show the label. (We might want this on 'show' views, not on partials.)
            //offset: 0, // we need to opt not to adjust the offset.
            onlyInteger: true
          },
          fullWidth: true,
          showLabel: false,
          axisX: {
            showGrid: false,
            showLabel: true
          },
          chartPadding: 0//,
          // ctThreshold isn't showing line when series is flat.
          //plugins: [
            //Chartist.plugins.ctThreshold({
              //threshold: 0
            //})
          //]
        });
      });
    });
  }

  function get_ledger_chart(){
    $(".ledger-chart").each(function(i,e){
      item = e
      ledger_id = $(e).attr('data-ledgerId');
      interval = $(e).attr('data-interval');
      $.ajax({ type: "GET", url: "/finances/charts/ledger_balance.json?ledger_id=" + ledger_id + "&interval_period=" + interval, cache: false }).success(function(chart_data){
        id = '#' + $(e).attr('id');
        keys = Object.keys(chart_data);
        values = keys.map(function(v) { return parseInt(chart_data[v]); });
        min = Math.min.apply( Math, values );
        max = Math.max.apply( Math, values );
        range = max - min;
        if (range == 0){
          range = 100
        }
        new Chartist.Line(id, {
          labels: keys,
          series: [
            values
          ]
        }, {
          low:min - range/10, // TODO: get highest and lowest from data, then add/substract some percentage of their range? Yep.
          high:max + range/10, // TODO: get highest and lowest from data, then add/substract some percentage of their range? Yep.
          lineSmooth: Chartist.Interpolation.none({
            // was cardinal. Should it be?
            // we should also variably select between cardinal and simple, dependent upon... the complexity of the data?
            // or not at all. I dunno.
          }),
          showPoint: true,
          showArea: true,
          axisY: {
            //showLabel: false, // if we want to show the label. (We might want this on 'show' views, not on partials.)
            //offset: 0, // we need to opt not to adjust the offset.
            onlyInteger: true
          },
          fullWidth: true,
          showLabel: false,
          axisX: {
            showGrid: false,
            showLabel: true
          },
          chartPadding: 0//,
          // ctThreshold isn't showing line when series is flat.
          //plugins: [
            //Chartist.plugins.ctThreshold({
              //threshold: 0
            //})
          //]
        });
      });
    });
  }

  function get_resource_chart(){
    $(".resource-chart").each(function(i,e){
      item = e
      resource_id = $(e).attr('data-resourceId');
      resource_type = $(e).attr('data-resourceClass');
      interval = $(e).attr('data-interval');
      $.ajax({ type: "GET", url: "/finances/charts/resource_balance.json?resource_id=" + resource_id + "&resource_type=" + resource_type + "&interval_period=" + interval, cache: false }).success(function(chart_data){
        id = '#' + $(e).attr('id');
        keys = Object.keys(chart_data);
        values = keys.map(function(v) { return parseInt(chart_data[v]); });
        min = Math.min.apply( Math, values );
        max = Math.max.apply( Math, values );
        range = max - min;
        if (range == 0){
          range = 100
        }
        new Chartist.Line(id, {
          labels: keys,
          series: [
            values
          ]
        }, {
          low:min - range/10, // TODO: get highest and lowest from data, then add/substract some percentage of their range? Yep.
          high:max + range/10, // TODO: get highest and lowest from data, then add/substract some percentage of their range? Yep.
          lineSmooth: Chartist.Interpolation.none({
            // was cardinal. Should it be?
            // we should also variably select between cardinal and simple, dependent upon... the complexity of the data?
            // or not at all. I dunno.
          }),
          showPoint: true,
          showArea: true,
          axisY: {
            //showLabel: false, // if we want to show the label. (We might want this on 'show' views, not on partials.)
            //offset: 0, // we need to opt not to adjust the offset.
            onlyInteger: true
          },
          fullWidth: true,
          showLabel: false,
          axisX: {
            showGrid: false,
            showLabel: true
          },
          chartPadding: 0//,
          // ctThreshold isn't showing line when series is flat.
          //plugins: [
            //Chartist.plugins.ctThreshold({
              //threshold: 0
            //})
          //]
        });
      });
    });
  }


  function get_wallet_chart_mini(){
    $(".wallet-chart-mini").each(function(i,e){
      item = e
      wallet_id = $(e).attr('data-walletId');
      interval = $(e).attr('data-interval');
      $.ajax({ type: "GET", url: "/finances/charts/wallet_balance.json?wallet_id=" + wallet_id + "&interval_period=" + interval, cache: false }).success(function(chart_data){
        id = '#' + $(e).attr('id');
        keys = Object.keys(chart_data);
        values = keys.map(function(v) { return parseInt(chart_data[v]); });
        min = Math.min.apply( Math, values );
        max = Math.max.apply( Math, values );
        range = max - min;
        if (range == 0){
          range = 100
        }
        new Chartist.Line(id, {
          labels: keys,
          series: [
            values
          ]
        }, {
          low:min - range/10, // TODO: get highest and lowest from data, then add/substract some percentage of their range? Yep.
          high:max + range/10, // TODO: get highest and lowest from data, then add/substract some percentage of their range? Yep.
          lineSmooth: Chartist.Interpolation.simple({
            // was cardinal. Should it be?
            // we should also variably select between cardinal and simple, dependent upon... the complexity of the data?
            // or not at all. I dunno.
          }),
          showPoint: false,
          showArea: true,
          axisY: {
            showLabel: false, // if we want to show the label. (We might want this on 'show' views, not on partials.)
            offset: 0, // we need to opt not to adjust the offset.
            onlyInteger: true
          },
          fullWidth: true,
          showLabel: false,
          axisX: {
            showGrid: false,
            showLabel: false
          },
          chartPadding: 0//,
          // ctThreshold isn't showing line when series is flat.
          //plugins: [
            //Chartist.plugins.ctThreshold({
              //threshold: 0
            //})
          //]
        });
      });
    });
  }


  function get_resource_chart_mini(){
    $(".resource-chart-mini").each(function(i,e){
      item = e
      resource_id = $(e).attr('data-resourceId');
      resource_type = $(e).attr('data-resourceClass');
      interval = $(e).attr('data-interval');
      $.ajax({ type: "GET", url: "/finances/charts/resource_balance.json?resource_id=" + resource_id + "&resource_type=" + resource_type + "&interval_period=" + interval, cache: false }).success(function(chart_data){
        id = '#' + $(e).attr('id');
        keys = Object.keys(chart_data);
        values = keys.map(function(v) { return parseInt(chart_data[v]); });
        min = Math.min.apply( Math, values );
        max = Math.max.apply( Math, values );
        range = max - min;
        if (range == 0){
          range = 100
        }
        new Chartist.Line(id, {
          labels: keys,
          series: [
            values
          ]
        }, {
          low:min - range/10, // TODO: get highest and lowest from data, then add/substract some percentage of their range? Yep.
          high:max + range/10, // TODO: get highest and lowest from data, then add/substract some percentage of their range? Yep.
          lineSmooth: Chartist.Interpolation.simple({
            // was cardinal. Should it be?
            // we should also variably select between cardinal and simple, dependent upon... the complexity of the data?
            // or not at all. I dunno.
          }),
          showPoint: false,
          showArea: true,
          axisY: {
            showLabel: false, // if we want to show the label. (We might want this on 'show' views, not on partials.)
            offset: 0, // we need to opt not to adjust the offset.
            onlyInteger: true
          },
          fullWidth: true,
          showLabel: false,
          axisX: {
            showGrid: false,
            showLabel: false
          },
          chartPadding: 0//,
          // ctThreshold isn't showing line when series is flat.
          //plugins: [
            //Chartist.plugins.ctThreshold({
              //threshold: 0
            //})
          //]
        });
      });
    });
  }


  $(document).ready(function(){
    if ($(".wallet-chart").length > 0){
      get_wallet_chart();
    }
    if ($(".ledger-chart").length > 0){
      get_ledger_chart();
    }
    if ($(".resource-chart").length > 0){
      get_resource_chart();
    }
    if ($(".wallet-chart-mini").length > 0){
      get_wallet_chart_mini();
    }
    if ($(".resource-chart-mini").length > 0){
      get_resource_chart_mini();
    }
  })
  $(document).on('page:load', function(){
    if ($(".wallet-chart").length > 0){
      get_wallet_chart();
    }
    if ($(".ledger-chart").length > 0){
      get_ledger_chart();
    }
    if ($(".resource-chart").length > 0){
      get_resource_chart();
    }
    if ($(".wallet-chart-mini").length > 0){
      get_wallet_chart_mini();
    }
    if ($(".resource-chart-mini").length > 0){
      get_resource_chart_mini();
    }
  })
}(jQuery));
