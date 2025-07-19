void main(void) {
    volatile char *video_memory = (char *) 0xB8000;
    const char *msg = "Hello from C!";

    for (int i = 0; msg[i] != '\0'; i++) {
        video_memory[i * 2] = msg[i];       // Character
        video_memory[i * 2 + 1] = 0x0E;     // Light yellow
    }

    while (1) {
        __asm__ __volatile__("hlt");
    }
}
