'use strict';
/* globals alert, _ */

import { Image } from '/src/Image.js';

const testing = true;
const testImageData = [
    { name: 'Test01', thumbnailUrl: '/images/Test01.jpg', resourceUrl: '/images/Test01.jpg', size: 7 },
    { name: 'Test02', thumbnailUrl: '/images/Test02.jpg', resourceUrl: '/images/Test02.jpg', size: 6 },
    { name: 'Test03', thumbnailUrl: '/images/Test03.jpg', resourceUrl: '/images/Test03.jpg', size: 5 },
    { name: 'Test04', thumbnailUrl: '/images/Test04.png', resourceUrl: '/images/Test04.png', size: 4 },
    { name: 'Test05', thumbnailUrl: '/images/Test05.jpg', resourceUrl: '/images/Test05.jpg', size: 3 },
    { name: 'Test07', thumbnailUrl: '/images/Test07.gif', resourceUrl: '/images/Test07.gif', size: 2 }
];

export class ImageStore {
    constructor() {
        this.images = [];
        this.sort = '';
        this.direction = 'up';
        this.skip = 0;
        this.limit = 3;
    }

    getTestImages(sortBy, direction, skip, limit, callback) {
        let imageData = testImageData;

        switch (sortBy) {
            case 'name':
                imageData = _.sortBy(testImageData, ['name']);
                break;

            case 'size':
                imageData = _.sortBy(testImageData, ['size']);
                break;
        }
        if (direction === 'descending') {
            imageData.reverse();
        }

        imageData = imageData.slice(skip, skip + limit);

        this.setImageData(imageData);

        callback();
    }

    getImages(sortBy, direction, skip, limit, callback) {
        if (testing) {
            return this.getTestImages(sortBy, direction, skip, limit, callback);
        }

        const url = `/images?sort=${sortBy}&direction=${direction}&skip=${skip}&limit=${limit}`;

        $.ajax({
            type: 'GET',
            url,
            data: {
            },
            success: function (imageData) {
                this.setImageData(imageData);
                callback();
            }.bind(this),
            error: function (error) {
                alert('Failed to get image data from server: \(error)');
                callback(error);
            }.bind(this)
        });
    }

    setImageData(imageData) {
        this.images = imageData.map(data => new Image(data));
    }

    addToElement(element) {
        element.empty();
        this.images.forEach(image => image.addToElement(element));
    }
}
