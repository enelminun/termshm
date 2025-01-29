# Maintainer: Kayra <your-email@example.com>
pkgname=termshm
pkgver=1.0.0
pkgrel=1
pkgdesc="Shortcut Manager'"
arch=('any')
url="https://github.com/enelminun/termshm"
license=('GPL3')
source=("termshm.sh")
sha256sums=('SKIP') 

package() {
  install -Dm755 "$srcdir/termshm.sh" "$pkgdir/usr/local/bin/termshm"
}
