(function (mousePosition) {
  
    function findAllImages() {
        return document.getElementsByTagName("img");
    }

    function getBoundingClientRects(imgs) {
        let imgClientRects = [];

        for (let i = 0; i < imgs.length; i++) {
            imgClientRects.push(imgs[i].getBoundingClientRect());
        }

        return imgClientRects;
    }

    function checkImageIntersection(position, images) {
        let imagesIntersected = [];

        for (let i = 0; i < images.length; i++) {
            const boundingRect = images[i].getBoundingClientRect();

            if (position.x >= boundingRect.left &&
                position.x <= boundingRect.right &&
                position.y >= boundingRect.top &&
                position.y <= boundingRect.bottom) {
                imagesIntersected.push(images[i])
            }
        }

        return imagesIntersected;
    }

    const images = findAllImages();
    const intersectingImages = checkImageIntersection(mousePosition, images);
 
    if (intersectingImages.length === 0) {
        return null;
    }
    else //if (intersectingImages.length === 1) {
        return intersectingImages[0].src;
//    } else {
//        return 'Multiple images matched';
//    }
 
})( { x: {x}, y: {y}} )
