let mousePosition = {
    x: null,
    y: null
};

document.addEventListener('mousemove', onMouseUpdate, false);
document.addEventListener('mouseenter', onMouseUpdate, false);

function onMouseUpdate(e) {
    mousePosition.x = e.pageX;
    mousePosition.y = e.pageY;
}

    
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
    
    return checkImageIntersection(mousePosition, images);
    
})( { x: 778, y: 644} )
