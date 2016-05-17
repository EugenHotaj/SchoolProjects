/*
   This file contains all the support routines and convenience functions.
*/

// Define a general purpose 3D vector object.

function Vector3() {
   this.x = 0;
   this.y = 0;
   this.z = 0;
}
Vector3.prototype = {
   set : function(x,y,z) {
      this.x = x;
      this.y = y;
      this.z = z;
   },
}

// Convenience function to get a string from contents of an HTML Script.

function getStringFromScript(id) {
   var str = '';
   var scriptNode = document.getElementById(id);
   for (var child = scriptNode.firstChild ; child ; child = child.nextSibling)
      if (child.nodeType == 3)
         str += child.textContent;
   return str;
}

function start_gl(canvas_id, vertexShader, fragmentShader) {
   setTimeout(function() {

      // Make sure the browser supports WebGL.

      try {
         var canvas = document.getElementById(canvas_id);
         window.gl = canvas.getContext("experimental-webgl");
      } catch (e) { throw "Sorry, your browser does not support WebGL."; }

      // Catch mouse events that go to the canvas.

      function setMouse(event, z) {
         var r = event.target.getBoundingClientRect();
         gl.cursor.x = (event.clientX - r.left  ) / (r.right - r.left) * 2 - 1;
         gl.cursor.y = (event.clientY - r.bottom) / (r.top - r.bottom) * 2 - 1;
         if (z !== undefined)
	    gl.cursor.z = z;
      }
      canvas.onmousedown = function(event) { setMouse(event, 1); } // On mouse down, set z to 1.
      canvas.onmousemove = function(event) { setMouse(event)   ; }
      canvas.onmouseup   = function(event) { setMouse(event, 0); } // On mouse up  , set z to 0.
      gl.cursor = new Vector3();

      // Initialize gl. Then start the frame loop.

      gl_init(gl, vertexShader, fragmentShader);
      gl_update(gl);

   }, 100); // Wait 100 milliseconds after page has loaded, before starting gl.
}

// Function to create and attach a shader to a gl program.

function addshader(gl, program, type, src) {
   var shader = gl.createShader(type);
   gl.shaderSource(shader, src);
   gl.compileShader(shader);
   if (! gl.getShaderParameter(shader, gl.COMPILE_STATUS))
      console.log("Cannot compile shader:\n\n" + gl.getShaderInfoLog(shader));
   gl.attachShader(program, shader);
};

// Initialize gl and create a square, given vertex and fragment shader defs.

function gl_init(gl, vertexShader, fragmentShader) {

   // Create and link the gl program, using the application's vertex and fragment shaders.

   var program = gl.createProgram();
   gl.program = program;
   addshader(gl, program, gl.VERTEX_SHADER  , vertexShader  );
   addshader(gl, program, gl.FRAGMENT_SHADER, fragmentShader);
   gl.linkProgram(program);
   if (! gl.getProgramParameter(program, gl.LINK_STATUS))
      console.log("Could not link the shader program!");
   gl.useProgram(program);

   // Create a square as a strip of two triangles.

   gl.bindBuffer(gl.ARRAY_BUFFER, gl.createBuffer());
   gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([ -1,1,0, 1,1,0, -1,-1,0, 1,-1,0 ]), gl.STATIC_DRAW);

   // Assign attribute aPosition to each of the square's vertices.

   gl.aPosition = gl.getAttribLocation(program, "aPosition");
   gl.enableVertexAttribArray(gl.aPosition);
   gl.vertexAttribPointer(gl.aPosition, 3, gl.FLOAT, false, 0, 0);
}

// Return the location in GPU memory of a uniform variable having the given name.

function uVar(name) {
   return gl.getUniformLocation(gl.program, name);
}

// gl_update() is called once per animation frame.

function gl_update(gl) {

   // Set a global variable counting how many seconds since the page was loaded.

   time = (new Date()).getTime() / 1000 - startTime;

   // If the application programmer has

   if (window.update)
      update();

   // Set values for some convenient uniform variables.

   gl.uniform3f (uVar('uCursor'), gl.cursor.x, gl.cursor.y, gl.cursor.z); // Set cursor uniform variable.
   gl.uniform1f (uVar('uTime'), time);                                  // Set time uniform variable.

   gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);                          // Render the square.
   requestAnimFrame(function() { gl_update(gl); });                 // Start the next frame.
}

// A browser-independent way to call a function after 1/60 second.

requestAnimFrame = (function(callback) {
      return requestAnimationFrame
          || webkitRequestAnimationFrame
          || mozRequestAnimationFrame
          || oRequestAnimationFrame
          || msRequestAnimationFrame
          || function(callback) { setTimeout(callback, 1000 / 60); }; })();

var startTime = (new Date()).getTime() / 1000;                          // Record the start time.
var time = 0;

