
// DEFINE A CONVENIENT 3D VECTOR OBJECT.

function Vector3(x, y, z) {
   this.x = 0;
   this.y = 0;
   this.z = 0;
   this.set(x, y, z);
}
Vector3.prototype = {
   set : function(x, y, z) {
      if (x !== undefined) this.x = x;
      if (y !== undefined) this.y = y;
      if (z !== undefined) this.z = z;
   },

   toString : function() {
      return '{x:' + this.x + ', y:' + this.y + ', z:' + this.z + '}';
   },

   // VIEWPORT TRANSFORM TO A SCREEN PIXEL LOCATION.

   viewportTransform : function(width, height, pixel) {
      pixel.x = (width  / 2) + this.x * (width / 2); 
      pixel.y = (height / 2) - this.y * (width / 2);
   }
}

