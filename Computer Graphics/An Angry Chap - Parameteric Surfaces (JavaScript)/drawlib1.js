
   // KEEP TRACK OF TIME IN SECONDS SINCE THE PAGE WAS LOADED.

   var startTime = (new Date()).getTime() / 1000, time = startTime;

   // MAINTAIN AN ARRAY OF 2D CANVASES, AND HAVE EACH CANVAS RESPOND TO MOUSE EVENTS.

   var canvases = [];
   function initCanvas(id) {
      var canvas = document.getElementById(id);
      canvas.setCursor = function(x, y, z) {
         var r = this.getBoundingClientRect();
	 this.cursor.set(x - r.left, y - r.top, z);
      }
      canvas.cursor = new Vector3(0, 0, 0);
      canvas.onmousedown = function(e) { this.setCursor(e.clientX, e.clientY, 1); }
      canvas.onmousemove = function(e) { this.setCursor(e.clientX, e.clientY   ); }
      canvas.onmouseup   = function(e) { this.setCursor(e.clientX, e.clientY, 0); }
      canvases.push(canvas);
      return canvas;
   }

   // ANIMATE BY CALLING EACH CANVAS'S update() FUNCTION, IF IT HAS ONE.

   function tick() {
      time = (new Date()).getTime() / 1000 - startTime;
      for (var i = 0 ; i < canvases.length ; i++)
         if (canvases[i].update) {
	    var canvas = canvases[i];
            var g = canvas.getContext('2d');
            g.clearRect(0, 0, canvas.width, canvas.height);
            canvas.update(g);
         }
      setTimeout(tick, 1000 / 60);
   }
   tick();
