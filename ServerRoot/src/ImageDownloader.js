/* globals window */
'use strict';

export class ImageDownloader {
    constructor() {
        this.intervalId = null;
    }

    prepareDownload(selection, callback) {
        if (selection === undefined) {
            // TODO: Download everything...
        } else {
            // TODO: Download just the selected media.
        }

        // setTimeout(() => {
        //     callback(null, {
        //         progressUrl: '/downloadProgress/1234'
        //     });
        // }, 1000);
        const url = `/prepareImagesForDownload`;

        $.ajax({
            type: 'POST',
            url,
            data: JSON.stringify(selection),
            success: (results) => {
                callback(null, results);
            },
            error: (jqXHR, textStatus, errorThrown) => {
                callback(`Failed to download file(s) from the server: ${errorThrown}`);
            }
        });
    }

    waitForPreparationToComplete(downloadId, progressCallback, completionCallback) {
        const url = `/downloadProgress/${downloadId}`;

        let percentage = 0;

        progressCallback(percentage);

        this.intervalId = setInterval(() => {
            $.ajax({
                type: 'GET',
                url,
                success: ({ status, downloadUrl, percentage }) => {
                    percentage = Math.max(Math.min(percentage, 100), 0);
                    progressCallback(percentage);

                    if (status === 'done') {
                        completionCallback(null, {
                            downloadUrl
                        });
                    }
                },
                error: (jqXHR, textStatus, errorThrown) => {
                    completionCallback(`Failed to download file(s) from the server: ${errorThrown}`);
                    clearInterval(this.intervalId);
                }
            });
        }, 1000);
    }

    getDownload(downloadUrl) {
        clearInterval(this.intervalId);

        window.open(downloadUrl, '_blank');
        // $.ajax({
        //     type: 'GET',
        //     url: downloadUrl,
        //     success: () => {
        //         callback();
        //     },
        //     error: (jqXHR, textStatus, errorThrown) => {
        //         callback(`Failed to download file(s) from the server: ${errorThrown}`);
        //     }
        // });
    }
}
