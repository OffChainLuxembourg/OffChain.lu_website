document.querySelectorAll('#eventsCarousel img').forEach(item => {
    item.addEventListener('click', function () {
        const modalImage = document.getElementById('modalImage');
        modalImage.src = this.src; // Set the source of the modal image to the source of the clicked image
        const modalTitle = document.getElementById('imageModalLabel');
        modalTitle.textContent = this.alt; // Optionally set the modal title to the alt text of the image
    });
});
