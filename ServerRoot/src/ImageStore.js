'use strict';
/* globals alert, _ */

import { Image } from '/src/Image.js';

const testing = false;
const testImageData = [
    { index: 0, name: 'Test01', width:  251, height:  201, title: 'Test01\nThis is text', thumbnailUrl: '/images/Test01.jpg', resourceUrl: '/images/Test01.jpg', size: 7, rating: 1, date: '2018-01-04T00:00:00Z' },
    { index: 1, name: 'Test02', width:  227, height:  222, title: 'Test02', thumbnailUrl: '/images/Test02.jpg', resourceUrl: '/images/Test02.jpg', size: 6, rating: 2, date: '2018-01-03T00:00:00Z' },
    { index: 2, name: 'Test03', width:  259, height:  194, title: 'Test03', thumbnailUrl: '/images/Test03.jpg', resourceUrl: '/images/Test03.jpg', size: 5, rating: 3, date: '2018-01-02T00:00:00Z' },
    { index: 3, name: 'Test04', width:  259, height:  194, title: 'Test04', thumbnailUrl: '/images/Test04.png', resourceUrl: '/images/Test04.png', size: 4, rating: 4, date: '2018-01-01T00:00:00Z' },
    { index: 4, name: 'Test05', width: 3840, height: 2160, title: 'Test05', thumbnailUrl: '/images/Test05.jpg', resourceUrl: '/images/Test05.jpg', size: 3, rating: 5, date: '2018-01-06T00:00:00Z' },
    { index: 5, name: 'Test07 with a really long name', width:  850, height:  567, title: 'Test07', thumbnailUrl: '/images/Test07.gif', resourceUrl: '/images/Test07.gif', size: 2, rating: 1, date: '2018-01-05T00:00:00Z' },
    { index: 6, name: 'LivePhotoTest', width:  3024, height: 4032, title: 'LivePhotoTest', thumbnailUrl: '/images/Test07.gif', resourceUrl: '/livephoto.html', size: 2, rating: 1, date: '2018-01-05T00:00:00Z', imageUrl: '/images/LivePhotoTest.jpeg', videoUrl: '/images/LivePhotoTest.mov' }
];

export class ImageStore {
    constructor() {
        this.images = [];
        this.imageMap = {};
        this.totalImages = 0;
    }

    getTestImages(sortBy, direction, skip, limit, callback) {
        let imageData = testImageData;

        switch (sortBy) {
            case 'none':
                imageData.sort((a, b) => a.index > b.index);
                break;

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
            error: (jqXHR, textStatus, errorThrown) => {
                alert(`Failed to get image data from server: ${errorThrown}`);
                callback(textStatus);
            }
        });
    }

    setImageData(imageData, totalImages) {
        this.totalImages = totalImages;
        this.totalPages = Math.ceil(totalImages / this.limit);

        this.images = imageData.map((data) => new Image(data));
        this.imageMap = {};
        this.images.forEach(image => {
            this.imageMap[image.id] = image;
        });
    }

    getImage(id) {
        return this.imageMap[id];
    }

    addToElement(element) {
        element.empty();
        this.images.forEach(image => image.addToElement(element));
    }

    resizeImagesTo(width, height = width, fitToAspect = true) {
        this.images.forEach(image => image.resizeTo(width, height, fitToAspect));
    }
}
