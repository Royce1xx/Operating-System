void main()
{
    char *video = (char *)0xB8000;
    const char *msg = "Welcome to RoyceOS!";
    for (int i = 0; msg[i] != '\0'; i++)
    {
        video[i * 2] = msg[i];
        video[i * 2 + 1] = 0x0E;
    }

    while (1)
    {
        __asm__ __volatile__("hlt");
    }
}
