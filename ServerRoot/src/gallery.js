'use strict';
/* globals console, $, _ */

import { ImageStore } from '/src/ImageStore.js';

const imageStore = new ImageStore();

const quantities = [
    { value: 5 },
    { value: 10 },
    { value: 20 },
    { value: 'All' }
];
const sortByItems = [
    { value: 'name' },
    { value: 'date' },
    { value: 'size' },
    { value: 'rating' }
];
const directionItems = [
    { value: 'ascending' },
    { value: 'descending' }
];

function makeOption({ value, text }) {
    text = text || value;
    return `<option value='${value}'>${text}</option>`;
}

function refreshGallery() {
    const sortBy = $('#sortBy').first().val();
    const direction = $('#direction').first().val();
    const offset = 0;
    const quantity = $('#quantity').first().val();

    imageStore.getImages(sortBy, direction, offset, quantity, (error) => {
        const galleryDiv = $('#gallery').first();
        galleryDiv.empty();
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

function populateSelectBox(selector, onChange, options) {
    const selectBox = $(selector);
    selectBox.change(onChange);
    options.forEach(item => selectBox.append(makeOption(item)));
}

export function pageLoaded() {
    console.log('pageLoaded');

    populateSelectBox('#sortBy', onSortByChange, sortByItems);
    populateSelectBox('#direction', onDirectionChange, directionItems);
    populateSelectBox('#quantity', onQuantityChange, quantities);

    refreshGallery();
}
