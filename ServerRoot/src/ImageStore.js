'use strict';
/* globals alert */

import { Image } from '/src/Image.js';

const testing = true;

export class ImageStore {
    constructor() {
        this.images = [];
        this.sort = '';
        this.direction = 'up';
        this.skip = 0;
        this.limit = 3;
    }

    getTestImages(sort, direction, skip, limit, callback) {
        this.setImageData([
            { thumbnailUrl: '/images/Test01.jpg', resourceUrl: '/images/Test01.jpg' },
            { thumbnailUrl: '/images/Test02.jpg', resourceUrl: '/images/Test02.jpg' },
            { thumbnailUrl: '/images/Test03.jpg', resourceUrl: '/images/Test03.jpg' },
            { thumbnailUrl: '/images/Test04.png', resourceUrl: '/images/Test04.png' },
            { thumbnailUrl: '/images/Test05.jpg', resourceUrl: '/images/Test05.jpg' },
            { thumbnailUrl: '/images/Test07.gif', resourceUrl: '/images/Test07.gif' },
        ]);
        callback();
    }

    getImages(sort, direction, skip, limit, callback) {
        if (testing) {
            return this.getTestImages(sort, direction, skip, limit, callback);
        }

        const url = `/images?sort=${sort}&direction=${direction}&skip=${skip}&limit=${limit}`;

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
