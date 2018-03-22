'use strict';
/* globals alert, _ */

import { Image } from '/src/Image.js';

const testing = true;
const testImageData = [
    { name: 'Test01', title: 'Test01\nThis is text', thumbnailUrl: '/images/Test01.jpg', resourceUrl: '/images/Test01.jpg', size: 7, rating: 1, date: '2018-01-04T00:00:00Z' },
    { name: 'Test02', title: 'Test02', thumbnailUrl: '/images/Test02.jpg', resourceUrl: '/images/Test02.jpg', size: 6, rating: 2, date: '2018-01-03T00:00:00Z' },
    { name: 'Test03', title: 'Test03', thumbnailUrl: '/images/Test03.jpg', resourceUrl: '/images/Test03.jpg', size: 5, rating: 3, date: '2018-01-02T00:00:00Z' },
    { name: 'Test04', title: 'Test04', thumbnailUrl: '/images/Test04.png', resourceUrl: '/images/Test04.png', size: 4, rating: 4, date: '2018-01-01T00:00:00Z' },
    { name: 'Test05', title: 'Test05', thumbnailUrl: '/images/Test05.jpg', resourceUrl: '/images/Test05.jpg', size: 3, rating: 5, date: '2018-01-06T00:00:00Z' },
    { name: 'Test07', title: 'Test07', thumbnailUrl: '/images/Test07.gif', resourceUrl: '/images/Test07.gif', size: 2, rating: 1, date: '2018-01-05T00:00:00Z' }
];

export class ImageStore {
    constructor() {
        this.images = [];
        this.totalImages = 0;
    }

    getTestImages(sortBy, direction, skip, limit, callback) {
        let imageData = testImageData;

        switch (sortBy) {
            case 'name':
                imageData.sort((a, b) => a.name > b.name);
                break;

            case 'size':
                imageData.sort((a, b) => a.size > b.size);
                break;

            case 'rating':
                imageData.sort((a, b) => a.rating > b.rating);
                break;

            case 'date':
                imageData.sort((a, b) => new Date(b.date) - new Date(a.date));
                break;
        }
        if (direction === 'descending') {
            imageData.reverse();
        }

        imageData = imageData.slice(skip, skip + limit);

        this.setImageData(imageData, testImageData.length);

        callback();
    }

    getImageTotals(callback) {
        if (testing) {
            this.totalImages = testImageData.length;
            return callback(null, this.totalImages);
        }

        const url = `/imageCount`;

        $.ajax({
            type: 'GET',
            url,
            data: {
            },
            success: (results) => {
                const { totalImages } = results;
                this.totalImages = totalImages;
                callback(null, this.totalImages);
            },
            error: (error) => {
                alert('Failed to get total number of images from server: \(error)');
                callback(error);
            }
        });
    }

    getImages(sortBy, direction, skip, limit, callback) {
        console.log(`getImages(${sortBy}, ${direction}, ${skip}, ${limit})`);

        if (testing) {
            return this.getTestImages(sortBy, direction, skip, limit, callback);
        }

        const url = `/images?sort=${sortBy}&direction=${direction}&skip=${skip}&limit=${limit}`;

        $.ajax({
            type: 'GET',
            url,
            data: {
            },
            success: (results) => {
                const { imageData, totalImages } = results;
                this.setImageData(imageData, totalImages);
                callback();
            },
            error: (error) => {
                alert('Failed to get image data from server: \(error)');
                callback(error);
            }
        });
    }

    setImageData(imageData, totalImages) {
        this.totalImages = totalImages;
        this.totalPages = Math.ceil(totalImages / this.limit);

        this.images = imageData.map(data => new Image(data));
    }

    addToElement(element) {
        element.empty();
        this.images.forEach(image => image.addToElement(element));
    }
}
