function handler(e) { e = e || window.event; console.log(e.pageX, e.pageY); } if (document.attachEvent) document.attachEvent('onclick', handler); else document.addEventListener('click', handler);



function toDataURL(url, callback){
    var xhr = new XMLHttpRequest();
    xhr.open('get', url);
    xhr.responseType = 'blob';
    xhr.onload = function(){
      var fr = new FileReader();
    
      fr.onload = function(){
        callback(this.result);
      };
    
      fr.readAsDataURL(xhr.response); // async call
    };
    
    xhr.send();
}

var result = {};
myImage = document.body.getElementsByTagName('img')[2]
toDataURL(myImage.src, function(dataURL){
  result.src = dataURL;

  // now just to show that passing to a canvas doesn't hold the same results
  var canvas = document.createElement('canvas');
  canvas.width = myImage.naturalWidth;
  canvas.height = myImage.naturalHeight;
  canvas.getContext('2d').drawImage(myImage, 0,0);

  console.log(canvas.toDataURL() === dataURL); // false - not same data
  });




  var base64Data = result.src.replace(/^data:image\/png;base64,/, "");

require("fs").writeFile("out.png", base64Data, 'base64', function(err) {
  console.log(err);
});