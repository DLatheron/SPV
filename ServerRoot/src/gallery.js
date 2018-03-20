'use strict';
/* globals console, $, _ */

import { ImageStore } from '/src/ImageStore.js';

const imageStore = new ImageStore();

const quantities = [ 5, 10, 20, 'All' ];

function makeOption(value, text = value) {
    return `<option value='${value}'>${text}</option>`;
}

function refreshGallery() {
    const sortBy = $('#sortBy').first().val();
    const direction = $('#direction').first().val();
    const offset = 0;
    const quantity = $('#quantity').first().val();

    imageStore.getImages(sortBy, direction, offset, quantity, (error) => {
        const galleryDiv = $('#gallery').first();
        imageStore.addToElement(galleryDiv);
    });
}

function onSortByChange(event) {
    console.log(`Sort By Changed to ${event.target.value}`);
    refreshGallery();
}

function onDirectionChange(event) {
    console.log(`Direction Changed to ${event.target.value}`);
    refreshGallery();
}

function onQuantityChange(event) {
    console.log(`Quantity Changed to ${event.target.value}`);
    refreshGallery();
}

export function pageLoaded() {
    console.log('pageLoaded');

    $('#sortBy').change(onSortByChange)
        .append(makeOption('name'))
        .append(makeOption('date'))
        .append(makeOption('size'))
        .append(makeOption('rating'));

    $('#direction').change(onDirectionChange)
        .append(makeOption('up', 'ascending'))
        .append(makeOption('down', 'descending'));

    $('#quantity').change(onQuantityChange)
    quantities.forEach(quantity => $('#quantity').append(makeOption(quantity)));

    refreshGallery();
}
